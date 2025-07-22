from api.cronCheckAll import cron_router_all
from api.routeCheckAll import http_router_all
from database.db import get_db
from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session
from database.CRUD.POST.User import post_User_CRUD_functions as UserCRUD
from database.schema.POST.User.user_schema import UserCreate
from database.models import User # Assuming User model is defined here
import json
from sqlalchemy.exc import IntegrityError

# It's better to manage the session within the handler to ensure it's fresh for each invocation.
def get_db_session():
    db_gen = get_db()
    db = next(db_gen)
    try:
        yield db
    finally:
        db.close()  # Properly close the session

def lambda_handler(event, context):
    """
    This Lambda function handles two types of events:
    1. A Cognito PostConfirmation trigger to create a user in the local database after sign-up.
    2. A standard API Gateway HTTP request.
    """
    db: Session = next(get_db_session())

    # 1. Handle Cognito PostConfirmation Trigger
    if event.get('triggerSource') == 'PostConfirmation_ConfirmSignUp' and event.get('userPoolId'):
        print("Cognito PostConfirmation trigger received.")
        print(event)
        try:
            user_attributes = event.get('request', {}).get('userAttributes', {})
            email = user_attributes.get('email')
            cognito_sub = user_attributes.get('sub')  # This is the unique user identifier from Cognitoå
            client_metadata = event.get('request', {}).get('clientMetadata', {}) # Get clientMetadata
            # Extract FCM token and platform from clientMetadata
            # Now using 'pushToken' for the device token
            push_token = client_metadata.get('fcm_device_token') # Client still sends 'fcm_device_token'
            # Determine initial push notification preference
            # Default to '1' (enabled) if a token is provided or no explicit 'false' is sent.
            # Store as string '1' or '0' as requested.
            push_enabled_str = '1'
            if client_metadata.get('push_notifications_enabled') == 'false': # If client explicitly disabled
                push_enabled_str = '0'

            # Construct the authData JSON object
            auth_data = {}
            auth_data['pushEnabled'] = push_enabled_str
            # Add other initial auth-related data to auth_data if needed

            if not email or not cognito_sub:
                error_msg = f"Email or Cognito sub not found in event. Email: {email}, Sub: {cognito_sub}."
                print(error_msg)
                raise ValueError(error_msg)

            # Check if the user already exists in the database to avoid duplicate insertions
            existing_user = db.query(User).filter(User.email == email).first()
            if existing_user:
                print(f"User with email {email} already exists. Skipping database insert.")
                return event  # Skip database creation if user exists.

            # Prepare the user data for database insertion.
            cognito_password = user_attributes.get('custom:passwordHashed')
            if not cognito_password:
                cognito_password = "COGNITO_MANAGED_USER"

            user_create_payload = UserCreate(
                email=email,
                passwordHashed=cognito_password,  # Placeholder for required field
                authToken=cognito_sub,
                cognitoUsername=cognito_sub,  # Set cognitoUsername to the Cognito sub
                pushToken=push_token, # Store FCM token in 'pushToken'
                authData=auth_data # Store pushEnabled in 'authData' JSON
            )
            
            print(f"Attempting to create user in DB: {email}")
            created_user_db = UserCRUD.createUser(user=user_create_payload, db=db)
            print(f"Successfully created user {created_user_db.email} (ID: {created_user_db.userId}) in DB from Cognito trigger.")

            # For the PostConfirmation trigger, Cognito expects the original event to be returned on success.
            return event

        except IntegrityError as e:
            # Handle database constraint violations (e.g., unique constraint violations).
            print(f"Database error creating user '{email}': {str(e)}")
            return {
                'statusCode': 500,
                'body': f"Database error: {str(e)}"
            }
        except Exception as e:
            # Log the error and re-raise to inform Cognito of the failure.
            print(f"Error processing Cognito trigger for user '{event.get('userName')}': {str(e)}")
            if hasattr(e, 'errors'):  # Pydantic ValidationError
                 error_details = e.errors()
                 print(f"Validation errors: {json.dumps(error_details)}")
                 raise Exception(f"Validation Error creating user from Cognito: {json.dumps(error_details)}")
            raise e

    elif event.get('triggerSource') == 'CRON' and event.get('scheduler-name'):
        print("CRON trigger received.")
        print(event)
        event['db_session'] = db
        returnString = cron_router_all(event)
        return jsonable_encoder(returnString)

    # 2. Handle API Gateway / HTTP Call
    else:
        print(event)
        # Existing API Gateway / HTTP call logic
        print("API Gateway or other HTTP trigger received.")
        event['db_session'] = db
        returnString = http_router_all(event)
        return jsonable_encoder(returnString)

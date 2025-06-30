from api.routeCheckAll import http_router_all
# Import the database session dependency
from database.db import get_db # Adjust import path if necessary
from fastapi.encoders import jsonable_encoder

# Imports for Cognito trigger functionality
from database.CRUD.POST.User import post_User_CRUD_functions as UserCRUD
from database.schema.POST.User.user_schema import UserCreate
from database.models import UserTypeEnum
import json # For logging or more detailed event inspection if needed

# Manually get the db session (as per existing code)
# Note: For robustness in a high-concurrency Lambda, consider obtaining a new session per invocation
# or using a session scope managed by the trigger type.
# However, sticking to the existing pattern for now:
db_gen = get_db()
db = next(db_gen)


def lambda_handler(event, context):
    # Check if the event is from a Cognito PostConfirmation trigger
    if event.get('triggerSource') == 'PostConfirmation_ConfirmSignUp' and event.get('userPoolId'):
        print("Cognito PostConfirmation trigger received.")
        try:
            user_attributes = event.get('request', {}).get('userAttributes', {})
            email = user_attributes.get('email')
            authToken = user_attributes.get('sub')
            # Cognito userName (event.get('userName')) is often the unique identifier used for sign-in.
            # It could be an email, phone number, or a preferred username based on Cognito settings.
            cognito_username = event.get('userName')

            cognito_password = user_attributes.get('passwordHashed')
            print("testing 2")
            print(event)
            print(cognito_password)

            if not email:
                error_msg = "Email not found in Cognito event's userAttributes. Cannot create user in DB."
                print(error_msg)
                # Raising an error here will signal to Cognito that this part of the confirmation failed.
                # Cognito might retry or handle this based on its configuration.
                raise ValueError(error_msg)
            
            if not cognito_password:
                cognito_password = user_attributes.get('custom:passwordHashed')
                print("pass1")
                print(cognito_password)

            if not cognito_password:
                cognito_password = "COGNITO_MANAGED_USER"
            
            if not authToken:
                authToken = "COGNITO_MANAGED_USER_auth_token"
            
            if authToken == cognito_username:
                cognito_username = email

            # Prepare the user data for your database
            # The 'passwordHashed' field is mandatory in your UserCreate schema.
            # Since Cognito manages the actual password, we use a placeholder.
            # The `create_user` CRUD function appends "notreallyhashed" to this.
            user_create_payload = UserCreate(
                email=email,
                username=cognito_username, # Map Cognito's userName to your DB username
                passwordHashed=cognito_password, # Placeholder
                userType=UserTypeEnum.email, # Default user type for Cognito sign-ups
                authToken=authToken
                # profileImg, deviceId, etc., will be None or their defaults unless extracted from Cognito
            )
            
            print(f"Attempting to create user in DB: {email}")
            created_user_db = UserCRUD.create_user(user=user_create_payload, db=db)
            print(f"Successfully created user {created_user_db.email} (ID: {created_user_db.userId}) in DB from Cognito trigger.")
            
            # For the PostConfirmation trigger, Cognito expects the original event to be returned if successful.
            return event

        except Exception as e:
            # Log the error and re-raise. This informs Cognito of the failure.
            # How Cognito handles this (e.g., retries) depends on its configuration.
            # If creating the user in your DB is critical for the user flow, re-raising is appropriate.
            print(f"Error processing Cognito PostConfirmation trigger for user '{event.get('userName')}': {str(e)}")
            # You might want to serialize the Pydantic validation errors more gracefully if 'e' is from Pydantic
            if hasattr(e, 'errors'): # Pydantic ValidationError
                 error_details = e.errors()
                 print(f"Validation errors: {json.dumps(error_details)}")
                 raise Exception(f"Validation Error creating user from Cognito: {json.dumps(error_details)}")
            raise e
    else:
        print(event)
        #return
        # Existing API Gateway / HTTP call logic
        print("API Gateway or other HTTP trigger received.")
        returnString = 'Invalid Call Parameters' # Default as in original
        # The db session is already globally available from the top of this script.
        # Ensure it's correctly passed or accessible to http_router_all as needed.
        event['db_session'] = db 
        returnString = http_router_all(event)
        return jsonable_encoder(returnString)
# lambda_function.py

import json
from sqlalchemy.orm import Session
from fastapi.encoders import jsonable_encoder
# Assuming UserTypeEnum is in database.models
from database.models import UserTypeEnum
from database.db import get_db
from database.schema.POST.User.user_schema import UserCreate
from database.CRUD.POST.User import post_User_CRUD_functions as UserCRUDPost
from database.CRUD.GET.User import get_User_CRUD_functions as UserCRUDGet # This likely points to functions in src/api/GET/User/get_User_functions.py
from api.routeCheckAll import http_router_all


# ----- KEY CHANGE: Import NotFoundException from the correct module -----
# Adjust the path "api.exceptions" if your project structure places it elsewhere
# relative to the lambda_function.py when deployed.
# For example, if your deployment package has an 'api' folder at the root:
from api.exceptions import NotFoundException
# If the 'api' folder is inside a 'src' folder that's at the root of your deployment package:
# from src.api.exceptions import NotFoundException

# This is for the non-Cognito part, ensure http_router_all is correctly imported
# from api.routeCheckAll import http_router_all # Assuming this path is correct for your deployment


def lambda_handler(event, context):
    print(f"Received event: {event}") # Log the entire event for debugging

    # Check if the event is from a Cognito PostConfirmation trigger
    if event.get('triggerSource') == 'PostConfirmation_ConfirmSignUp' and event.get('userPoolId'):
        print("Cognito PostConfirmation trigger received.")
        db: Session = None
        try:
            # Ensure get_db() provides a SQLAlchemy session correctly
            db_gen = get_db()
            db = next(db_gen)
            print("Database session obtained.")

            user_attributes = event.get('request', {}).get('userAttributes', {})
            email = user_attributes.get('email')
            cognito_username = event.get('userName') # This is usually the Cognito sub or preferred_username

            # It's good practice to also get the Cognito User Sub (unique ID)
            cognito_sub = user_attributes.get('sub')
            print(f"User attributes: email='{email}', cognito_username='{cognito_username}', cognito_sub='{cognito_sub}'")


            if not email:
                error_msg = "Email not found in Cognito event's userAttributes. Cannot create user in DB."
                print(error_msg)
                # To inform Cognito of a failure, you should raise an exception.
                # Simply returning the event might be interpreted as success by Cognito.
                raise ValueError(error_msg)

            user_to_create = False # Default to not creating, will be set to True if user not found
            existing_user_data = None

            try:
                print(f"Checking if user with email '{email}' exists in DB...")
                # UserCRUDGet.getUserByEmail is the function from src/api/GET/User/get_User_functions.py
                # It now correctly uses the imported NotFoundException
                existing_user_db = UserCRUDGet.getUserByEmail(email=email, db=db) # This function expects email as a direct arg, not Query
                
                if existing_user_db:
                    print(f"User with email '{email}' already exists in DB. User ID: {existing_user_db.userId}")
                    # If user exists, add their info to the event and return.
                    # Cognito expects the original event to be returned, possibly modified.
                    event['user_database_record'] = jsonable_encoder(existing_user_db)
                    existing_user_data = existing_user_db # Store for later use if needed
                    # No need to create, so user_to_create remains False
                else:
                    # This case should ideally not be hit if getUserByEmail raises NotFoundException
                    # or returns None consistently. If it returns None and doesn't raise, this logic is fine.
                    print(f"UserCRUDGet.getUserByEmail returned None for email '{email}', but did not raise NotFoundException. Assuming user does not exist.")
                    user_to_create = True


            except NotFoundException:
                # This is the expected path for a new user who isn't in the DB yet.
                print(f"User with email '{email}' does not exist in DB (NotFoundException caught). Proceeding to create.")
                user_to_create = True
            # Any other unexpected exception from UserCRUDGet.getUserByEmail would fall through to the outer except block.


            if user_to_create:
                print(f"Preparing to create new user in DB for email: {email}")
                # Ensure username is unique if your DB requires it.
                # Cognito's event.userName might be the 'sub' or another attribute.
                # You might want to use email as username or generate one if cognito_username is not suitable.
                # For this example, using cognito_username directly.
                
                # Make sure the UserCreate schema matches what UserCRUDPost.create_user expects
                user_create_payload = UserCreate(
                    email=email,
                    username=cognito_username, # Or derive a unique username if needed
                    passwordHashed="COGNITO_MANAGED_USER", # Placeholder as Cognito handles auth
                    userType=UserTypeEnum.email, # Default user type
                    # Add any other required fields for UserCreate schema, e.g., cognitoSub=cognito_sub
                    # cognitoSub=cognito_sub # Example if your UserCreate schema has this
                )
                print(f"User creation payload: {user_create_payload.dict()}")

                created_user_db = UserCRUDPost.create_user(user=user_create_payload, db=db)
                print(f"Successfully created user {created_user_db.email} (ID: {created_user_db.userId}, DB Username: {created_user_db.username}) in DB from Cognito trigger.")
                event['user_database_record'] = jsonable_encoder(created_user_db)
            
            # Always return the event to Cognito, modified or not
            print(f"Returning event to Cognito: {json.dumps(event)}")
            return event

        except Exception as e:
            # Log the error and re-raise. This informs Cognito of the failure.
            # Be careful about what information you log, especially sensitive data.
            error_type = type(e).__name__
            print(f"Error processing Cognito PostConfirmation trigger for Cognito user '{event.get('userName')}'. Exception Type: {error_type}, Error: {str(e)}")
            
            # If it's a Pydantic ValidationError, log details if helpful
            if hasattr(e, 'errors') and callable(e.errors):
                try:
                    error_details = e.errors()
                    print(f"Pydantic validation errors: {json.dumps(error_details)}")
                    # Raise a more generic exception or a specific one Cognito might handle
                    raise Exception(f"Validation Error creating user from Cognito: {json.dumps(error_details)}") from e
                except Exception as pe:
                    print(f"Error while processing pydantic errors: {str(pe)}")


            # Re-raise the original exception to signal failure to Cognito
            raise
        finally:
            if db:
                print("Closing database session.")
                db.close()
    else:
        # Existing API Gateway / HTTP call logic
        print("Non-Cognito trigger received (API Gateway or other HTTP).")
        db: Session = None
        try:
            db_gen = get_db()
            db = next(db_gen)
            print("Database session obtained for HTTP request.")
            # Ensure event has what http_router_all expects.
            # If http_router_all expects db_session in event:
            event['db_session'] = db
            
            return_string = http_router_all(event)
            print(f"http_router_all returned: {return_string}")
            return jsonable_encoder(return_string)
        except Exception as e:
            error_type = type(e).__name__
            print(f"Error in HTTP processing part. Exception Type: {error_type}, Error: {str(e)}")
            # Consider returning a proper HTTP error response if this is for API Gateway
            # For example: return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
            raise # Or handle more gracefully for HTTP responses
        finally:
            if db:
                print("Closing database session for HTTP request.")
                db.close()
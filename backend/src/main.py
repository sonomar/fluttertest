from fastapi import FastAPI, Request, Query
from pydantic import BaseModel, Field
from typing import Any, Dict, List, Optional
from tools.dev.devTools import create_obj, get_all_active_paths_object, create_obj_get
from lambda_function import lambda_handler
from api.GET.api_paths_get import API_PATHS_GET
from api.POST.api_paths_post import API_PATHS_POST
from api.PATCH.api_paths_patch import API_PATHS_PATCH
from api.DELETE.api_paths_delete import API_PATHS_DELETE

# Collect paths
get_paths_object = get_all_active_paths_object(API_PATHS_GET)
patch_paths_object = get_all_active_paths_object(API_PATHS_PATCH)
post_paths_object = get_all_active_paths_object(API_PATHS_POST)
delete_paths_object = get_all_active_paths_object(API_PATHS_DELETE)

Handler_Local_Type = True

app = FastAPI()

# Define Pydantic model for body validation
class JSONBody(BaseModel):
    Dict[Any, Any]

# Root route to detect subdomain
@app.get("/")
async def root(request: Request):
    host = request.headers.get("host", "")
    subdomain = host.split(".")[0] if host else "unknown"
    return {"subdomain": subdomain, "message": f"Hello from {subdomain}!"}

# Shared handler for GET requests
async def shared_handler(request: Request, tableName: Optional[str] = None, input: Optional[JSONBody] = None):
    event = await create_obj(request)
    return lambda_handler(event, request)

# Shared handler for multiple paths
async def shared_handler_get(request: Request, tableName: Optional[str] = None, input: Optional[Any] = None):
    jsonBody = input if input else await request.body()
    event = await create_obj_get(request, jsonBody)
    return lambda_handler(event, request)


# Helper function to register routes
def register_routes(paths_obj: list, method: str, handler: callable):
    for path_obj in paths_obj:
 # Ensure path and pathLocal are strings
        path = path_obj.get("path", "")
        path_local = path_obj.get("pathLocal", "")
        
        # If path or pathLocal are dictionaries, extract the correct string key
        if isinstance(path, dict):
            # Replace 'some_key' with the appropriate key you need from the dictionary
            path = path.get("some_key", "")  # Adjust this line based on your structure
        if isinstance(path_local, dict):
            # Similarly handle pathLocal if it's a dict
            path_local = path_local.get("some_key", "")  # Adjust this line
        
        # Use pathLocal if it's available, otherwise fallback to path
        path_local = path_local if path_local else path

        # Dynamically build the full path
        full_path = '/{tableName}' + (path if not Handler_Local_Type else path_local)
        
        # Now register the route
        app.add_api_route(
            full_path,
            handler if not Handler_Local_Type else path_obj.get("handler", handler),  # Fallback to original handler if missing
            methods=[method],
            response_model=path_obj.get("response_model", None),  # Handle response_model fallback
            status_code=200,
            response_description="Successful operation",
            description=f"Create or manage item at {full_path}",
        )

# Register GET routes
register_routes(get_paths_object, "GET", shared_handler_get)

# Register POST routes
register_routes(post_paths_object, "POST", shared_handler)

# Register PATCH routes
register_routes(patch_paths_object, "PATCH", shared_handler)

# Register DELETE routes
register_routes(delete_paths_object, "DELETE", shared_handler)

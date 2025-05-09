from fastapi import FastAPI, Request
from pydantic import BaseModel
from typing import Any, Dict, Optional


from tools.dev.devTools import create_obj, collect_raw_paths, create_obj_get
from lambda_function import lambda_handler

import api.GET.api_path_get as getPath
import api.POST.api_path_post as postPath
import api.PATCH.api_path_patch as patchPath
import api.DELETE.api_path_delete as deletePath 

# Collect paths
get_paths = collect_raw_paths(getPath)
patch_paths = collect_raw_paths(patchPath)
post_paths = collect_raw_paths(postPath)
delete_paths = collect_raw_paths(deletePath)


app = FastAPI()

# Define Pydantic model for body validation
class JSONBody(BaseModel):
    Dict[Any, Any]



# @app.get("/")
# def read_root():
#     return {"message": "Hello, World!"}

# @app.get("/getCollectibleByCollectibleId")
# async def get_collectible_by_collectible_id(request: Request):

#     event = await create_obj(request)
#     return lambda_handler(event, request)

# @app.patch("/updateUserByUserId")
# async def get_Project_By_Project_id(request: Request):
#     event = await create_obj(request)
#     return lambda_handler(event, request)

# Root route to detect subdomain
@app.get("/")
async def root(request: Request):
    host = request.headers.get("host", "")
    subdomain = host.split(".")[0] if host else "unknown"
    return {"subdomain": subdomain, "message": f"Hello from {subdomain}!"}


# Shared handler for multiple paths
async def shared_handler(request: Request, tableName: Optional[str] = None, input: Optional[JSONBody] = None):
    event = await create_obj(request)
    return lambda_handler(event, request)

# Shared handler for multiple paths
async def shared_handler_get(request: Request, tableName: Optional[str] = None, input: Optional[Any] = None):
    jsonBody = input if input else await request.body()
    event = await create_obj_get(request, jsonBody)
    return lambda_handler(event, request)

# Helper function to register routes
def register_routes(paths: list, method: str, handler: callable):
    for path in paths:
        app.add_api_route('/{tableName}' + path, handler, methods=[method])

# Register GET routes
register_routes(get_paths, "GET", shared_handler_get)

# Register POST routes
register_routes(post_paths, "POST", shared_handler)

# Register PATCH routes
register_routes(patch_paths, "PATCH", shared_handler)

# Register DELETE routes
register_routes(delete_paths, "DELETE", shared_handler)
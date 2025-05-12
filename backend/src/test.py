from api.GET.api_paths_get import API_PATHS_GET
from tools.dev.devTools import get_all_active_paths_object

# Collect paths
get_paths = get_all_active_paths_object(API_PATHS_GET)
#print(get_paths)

def register_routes(paths: list):
    for path in paths:
        print(path["path"], path["input"], path["output"])
        break

# Register GET routes
register_routes(get_paths)
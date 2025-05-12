#from table import *  # Assuming necessary table constants are defined here
async def create_obj(request):
    """Creates an event object by embedding a key-value pair and request metadata."""

    event = {
    "headers": {
        "content-length": "19",
        "x-amzn-tls-version": "TLSv1.3",
        "x-forwarded-proto": "https",
        "postman-token": "ed1d8e39-eb7a-4406-8c44-35d6a146340b",
        "x-forwarded-port": "443",
        "x-forwarded-for": "95.91.243.147",
        "accept": "*/*",
        "x-amzn-tls-cipher-suite": "TLS_AES_128_GCM_SHA256",
        "x-amzn-trace-id": "Root=1-68186800-7f06df25668a0f9d06bdc68f",
        "host": "l2gvl5jlxi5x5y3uzcqubcozy40yuzeh.lambda-url.eu-central-1.on.aws",
        "content-type": "application/json",
        "accept-encoding": "gzip, deflate, br",
        "user-agent": "PostmanRuntime/7.43.3"
    },
    "isBase64Encoded": False,
    "rawPath": request.url.path,
    "routeKey": "$default",
    "requestContext": {
        "accountId": "anonymous",
        "timeEpoch": 1746429952151,
        "routeKey": "$default",
        "stage": "$default",
        "domainPrefix": "l2gvl5jlxi5x5y3uzcqubcozy40yuzeh",
        "requestId": "8031ac77-50b7-40c5-8a6e-d57bf79dedb6",
        "domainName": "l2gvl5jlxi5x5y3uzcqubcozy40yuzeh.lambda-url.eu-central-1.on.aws",
        "http": {
            "path": request.url.path,
            "protocol": "HTTP/1.1",
            "method": request.method,
            "sourceIp": "95.91.243.147",
            "userAgent": "PostmanRuntime/7.43.3"
        },
        "time": "05/May/2025:07:25:52 +0000",
        "apiId": "l2gvl5jlxi5x5y3uzcqubcozy40yuzeh"
    },
    "queryStringParameters": request.query_params,
    "body": await request.body() ,
    "version": "2.0",
    "rawQueryString": request.query_params
    }

    return event


async def create_obj_get(request, bodyParam):
    """Creates an event object by embedding a key-value pair and request metadata."""

    event = {
    "headers": {
        "content-length": "19",
        "x-amzn-tls-version": "TLSv1.3",
        "x-forwarded-proto": "https",
        "postman-token": "ed1d8e39-eb7a-4406-8c44-35d6a146340b",
        "x-forwarded-port": "443",
        "x-forwarded-for": "95.91.243.147",
        "accept": "*/*",
        "x-amzn-tls-cipher-suite": "TLS_AES_128_GCM_SHA256",
        "x-amzn-trace-id": "Root=1-68186800-7f06df25668a0f9d06bdc68f",
        "host": "l2gvl5jlxi5x5y3uzcqubcozy40yuzeh.lambda-url.eu-central-1.on.aws",
        "content-type": "application/json",
        "accept-encoding": "gzip, deflate, br",
        "user-agent": "PostmanRuntime/7.43.3"
    },
    "isBase64Encoded": False,
    "rawPath": request.url.path,
    "routeKey": "$default",
    "requestContext": {
        "accountId": "anonymous",
        "timeEpoch": 1746429952151,
        "routeKey": "$default",
        "stage": "$default",
        "domainPrefix": "l2gvl5jlxi5x5y3uzcqubcozy40yuzeh",
        "requestId": "8031ac77-50b7-40c5-8a6e-d57bf79dedb6",
        "domainName": "l2gvl5jlxi5x5y3uzcqubcozy40yuzeh.lambda-url.eu-central-1.on.aws",
        "http": {
            "path": request.url.path,
            "protocol": "HTTP/1.1",
            "method": request.method,
            "sourceIp": "95.91.243.147",
            "userAgent": "PostmanRuntime/7.43.3"
        },
        "time": "05/May/2025:07:25:52 +0000",
        "apiId": "l2gvl5jlxi5x5y3uzcqubcozy40yuzeh"
    },
    "queryStringParameters": request.query_params,
    "body": bodyParam,
    "version": "2.0",
    "rawQueryString": request.query_params
    }

    return event


def collect_raw_paths(module):
    return [
        value for name, value in vars(module).items()
        if name.startswith(('GET_RAW_PATH_', 'CREATE_RAW_PATH_', 'UPDATE_RAW_PATH_', 'DELETE_RAW_PATH_'))
    ]

def get_all_active_paths(api_paths):
    paths = []
    for table, endpoints in api_paths.items():
        for endpoint_name, endpoint_info in endpoints.items():
            if endpoint_info.get("active"):
                paths.append(endpoint_info.get("path"))
    return paths

def get_all_active_paths_object(api_paths: list):
    paths = []
    for table, endpoints in api_paths.items():
        for endpoint_name, endpoint_info in endpoints.items():
            if endpoint_info.get("active"):
                paths.append({
                    "path": endpoint_info.get("path"),
                    "input": endpoint_info.get("input", {}),
                    "output": endpoint_info.get("output", {})
                })
    return paths

# Usage
#all_paths = get_all_active_paths(GET_API_PATHS)
#print(all_paths)

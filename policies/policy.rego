package envoy.authz
import rego.v1

import input.attributes.request.http as http_request

default allow := false

# Allow POST requests if the user has the required role.
allow if {
    http_request.method == "POST"
    http_request.path == "/api/v3.0/shells"
    has_post_permission
}

# Allow GET requests unconditionally.
allow if {
    http_request.method == "GET"
}


# Check if the user has a role that allows POST requests.
has_post_permission if {
    claims.realm_access.roles[_] in post_users 
}

# Users with permissions to add new AAS.
post_users := {
    "student",
    "wimi",
    "admin"
}

# Decode the JWT and extract claims.
claims := payload if {
    v := http_request.headers.authorization # Retrieve the 'Authorization' header from the HTTP request
    startswith(v, "Bearer ")
    t := substring(v, count("Bearer "), -1) # Extract the JWT token by removing the 'Bearer ' prefix
    [_, payload, _] := io.jwt.decode(t)  # Decode the JWT token to extract the payload (claims)
}

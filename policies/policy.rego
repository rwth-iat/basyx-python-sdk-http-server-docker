package envoy.authz

import rego.v1

import input.attributes.request.http as http_request

default allow := false


allow if {
    http_request.method == "POST"
    http_request.path == "/api/v3.0/shells"
}

allow if {
    http_request.method == "GET"
}

allow if {
    http_request.method == "DELETE"
    http_request.path == "/api/v3.0/shells/http://acplt.org/Test_Asset"
}




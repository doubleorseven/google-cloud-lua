local url = require "socket.url"
local ltn12 = require "ltn12"
local json = require "cjson"
local http = require "ssl.https"
local HTTPClient = require "google.core.http"
local scopes = "https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/pubsub"


local _M = {}


function construct(self,oauth)
  return setmetatable({
    httpClient = HTTPClient(oauth,"content-pubsub.googleapis.com"),
    _project_id = oauth:GetProjectID()
  }, {__index = _M})    
end

setmetatable(_M, {__call = construct,__type = "pubsub.Client"})
return _M



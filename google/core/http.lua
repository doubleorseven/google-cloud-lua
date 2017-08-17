local url = require "socket.url"
local ltn12 = require "ltn12"
local json = require "cjson"
local http = require "ssl.https"

local _M = {}


function _M:Request(path,data,headers,method)
    if data == nil then
    data = ""
    elseif type(data) == "table" then
      data = json.encode(data)
    end
    if method == nil then
      method = "POST"
      headers = { ["Content-length"] = #data }
    end
    if headers == nil then
      headers = {}
    else
      headers = self.extend_headers(self.get_basic_headers(self), headers)
    end
    local out = { }
    local r = {
    url = url.build({
      scheme = "https",
      host = self._base_url,
      path = path,
      query = "alt=json"
    }),
    source = data and ltn12.source.string(data),    
    method = method,
    headers = headers,
    sink = ltn12.sink.table(out)
    }
    local _, code, res_headers = http.request(r)
    return out
  end

function construct(self,oauth,base_url)
  return setmetatable({
  _oauth = oauth,
  _project_id = oauth:GetProjectID(),
  _base_url = base_url,
  _kind = nil,
  get_basic_headers = function(self)
    return {
      ["Content-type"] = "application/json",
      ["Authorization"] = "Bearer " .. tostring(self._oauth:GetAccessToken())
    }
  end,
  extend_headers  = function(headers, ...)
    local extra_headers = {...}
    for i = 1, #extra_headers do
      local extra = extra_headers[i]
      if extra ~= nil then
        for k, v in pairs(extra) do
          headers[k] = v
        end
      end
    end
    return headers
  end
  }, {__index = _M})    
end

setmetatable(_M, {__call = construct,__type = "google.core.HTTP"})
return _M

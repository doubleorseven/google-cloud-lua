local http = require "ssl.https"
 local json = require "cjson"
 local mime = require "mime"
 local crypto = require "crypto"
 local url = require "socket.url"
 
 local _M = {}
 
 
 function _M:GetAccessToken()
   return self.generate_access_token(self)
 end
 
 function _M:SignString(string_to_sign)
   return self.sign_string(self, string_to_sign)
 end
 
 function _M:GetClientEmail()
   return self._client_email
 end
 
 function _M:GetProjectID()
   return self._project_id
 end
 
 function read_key_return_json(path)
   local file = io.open(path, "r")
   if file then
     local contents = file:read("*a")
     key_table = json.decode(contents);
     io.close(file)
     if type(key_table) == "table" then
       return key_table
     end
     end
 return nil
 end
 
 function params_builder(tbl)
   local tuples do
     local keyval = {}
     local index = 1
     for k, v in pairs(tbl) do
       keyval[index] = tostring(url.escape(k)) .. "=" .. tostring(url.escape(v))
       index = index + 1
     end
     tuples = keyval
   end
   return table.concat(tuples, "&")
 end
 
 
 function construct(self, key_path, scope)
   local self
   key_table = read_key_return_json(key_path)
   if key_table then
     self = setmetatable({
     _client_email = key_table.client_email,
     _private_key = key_table.private_key,
     _project_id = key_table.project_id,
     _access_token = nil,
     _access_token_expire_time = nil,
     _scope = scope,
     _auth_token_url = key_table.token_uri,
     generate_access_token = function(self)
     if not self._access_token or os.time() > self._access_token_expire_time then
       self.refresh_access_token(self)
     end
     return self._access_token
   end,
   refresh_access_token = function(self)
   local time = os.time()
   local jwt = self.make_jwt(self)
   local req_params = params_builder({
     grant_type = "urn:ietf:params:oauth:grant-type:jwt-bearer",
     assertion = jwt
   })
 
   local res = assert(http.request(self._auth_token_url, req_params))
   res = json.decode(res)
 
   if res.error then
     error("Failed auth: " .. tostring(res.error))
   end
   self._access_token_expire_time = time + res.expires_in
   self._access_token = res.access_token
   end,
   make_jwt = function(self)
   local claims = json.encode({
     iss = self._client_email,
     aud = self._auth_token_url,
     scope = self._scope,
     iat = os.time(),
     exp = os.time() + (60 * 60)
   })
   local sign_input = mime.b64('{"alg":"RS256","typ":"JWT"}') .. "." .. mime.b64(claims)
   local signature = self.sign_string(self, sign_input)
   return sign_input .. "." .. signature
   end,
   sign_string = function(self, string_to_sign)
   return (mime.b64(crypto.sign("sha256WithRSAEncryption", string_to_sign, assert(crypto.pkey.from_pem(self._private_key, true)))))
   end}, {__index = _M})
   end
 return self
 end
 
 setmetatable(_M, {__call = construct, __type = "google.core.OAuth"})
 return _M

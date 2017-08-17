local url = require "socket.url"
local ltn12 = require "ltn12"
local json = require "cjson"
local http = require "ssl.https"
local Transaction = require "google.datastore.transaction"
local HTTPClient = require "google.core.http"
local scopes = "https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/datastore"


local _M = {}


function _M:getScopes()
  return scopes
end

function _M:SetKind(kind)
  self._kind = kind
end

function _M:AllocatedIds(cap)
  if self._kind and cap and #cap > 0 then
    local data = { keys = { path = {} } }
    for i=0,#cap,1 do
      local eObj = {}
      eObj.kind = self._kind
      data.keys.path[#data.keys+1] = eObj
    end
    return self.httpClient:Request(path_builder("allocateIds"),data)
  end
  return nil
end

function _M:BeginTransaction(do_transaction)
  if do_transaction == nil then
    return Transaction(self._project_id)
  end
  if self._kind then
    local result = self.httpClient:Request(path_builder(self,"beginTransaction"))
    if result["transaction"] ~= nil then
      return Transaction(self._project_id,result["transaction"],"TRANSACTIONAL")
    end
  end
  return nil
end

function _M:Commit(transaction)
  if self._kind then
    local data = {}
    if transaction["transaction"] then
      data["transaction"] = transaction["transaction"]
    end 
    data["mode"] = transaction["mode"]
    data["mutations"] = transaction["mutations"]
    local result = self.httpClient:Request(path_builder(self,"commit"),json.encode(data))
    return true
  end
  return nil
end

function _M:Rollback(transaction)
  if self._kind and transaction then
    data = { transaction = transaction["transaction"] }
    local result = self.httpClient:Request(path_builder("rollback"),json.encode(data))
    if result["error"] ~= nil then
      return false
    end
    return true
  end
  return false
end

function _M:Lookup(entity)
  if entity then
    entities = {entity}
    local result = self.httpClient:Request(path_builder(self,"lookup"),lookup_data_builder(self,entities))
    if result and #result > 0 then
      result_json = json.decode(result[1])
      if result_json["found"] and type(result_json["found"]) == "table" then
        return result_json["found"]
      end
    end
    return nil
  end   
end

function _M:MultiLookup(entities)
  if entities then
    return self.httpClient:Request(path_builder(self,"lookup"),lookup_data_builder(self,entities))
  end
  return nil
end

function _M:Query(gql_query,allow_literals)
  data = { gqlQuery = {} }
  data.gqlQuery["queryString"] = gql_query
  data.gqlQuery["allowLiterals"] = allow_literals or true
  local result = self.httpClient:Request(path_builder(self,"runQuery"),json.encode(data))
  return result
end


function path_builder(self,action)
  return string.format("/v1/projects/%s:%s",self._project_id,action)
end

function lookup_data_builder(self,entities)
  if entities and #entities > 0 then
    local data = { keys = { } }
    for index, entity in pairs(entities) do
      local index = #data.keys+1
      data.keys[index] = { path ={} }
      local kObj = { }
      kObj.kind = self._kind
      kObj.name = entity
      data.keys[index].path = kObj
    end
    return json.encode(data)
  end
  return nil
end


function construct(self,oauth)
  return setmetatable({
  httpClient = HTTPClient(oauth,"datastore.google.com"),
  _project_id = oauth:GetProjectID(),
  _kind = nil}, {__index = _M})    
end

setmetatable(_M, {__call = construct,__type = "datastore.Client"})
return _M



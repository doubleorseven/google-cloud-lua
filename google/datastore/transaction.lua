local Entity = require "google.datastore.entity"
local _M = {}


function _M:NewMutation()
  local index = #self.mutations+1
  self.mutations[index] = {}
  return index
end

function _M:CreateEntity(namespace_id)
  return Entity(self.project_id,namespace_id or nil)
end

function _M:Insert(index,entity)
  self.add_operation(self,index,"insert",entity)
end

function _M:Update(index,entity)
  self.add_operation(self,index,"update",entity)
end

function _M:Upsert(index,entity)
  self.add_operation(self,index,"upsert",entity)
end

function _M:Delete(index,key)
  self.add_operation(self,index,"delete",key)
end

function _M:BaseVersion(index,version_id)
  self.add_operation(self,index,"baseVersion",version_id)
end

function construct(self,project_id,transaction_id,mode)
  local self = setmetatable({ 
    trnasction = transaction_id or nil,
    mode = mode or "NON_TRANSACTIONAL", 
    mutations = {},
    project_id = project_id,
    add_operation = function(self,index,operation,entity)
      if self.mutations[index][operation] ~= nil then
        return false
      end
      self.mutations[index][operation] = {}
      if operation == "delete" then
	      self.mutations[index][operation]["path"] = entity.key.path
      else
	      self.mutations[index][operation]["key"] = entity.key
        self.mutations[index][operation]["properties"] = entity.properties
      end
    end}, {__index = _M })
  return self
end

setmetatable(_M, {__call = construct,__type = "datastore.Transaction"})
return _M

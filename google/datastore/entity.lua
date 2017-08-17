local _M = {}
function _M:AddPath(kind,id,name)
  self.add_path(self,kind,id or nil,name or nil)
end

function _M:SetProperty(key,value,key_type,index)
  self.set_property(self,key,value,key_type or type(value),index or false)
end

local function construct(self,project_id,namespace_id)
  local partition_id = {}
  partition_id["projectId"] = project_id
  partition_id["namespaceId"] = namespace_id or nil
  local self = setmetatable({
    key = { partitionId = partition_id , path = {} },
    properties = {},
    add_path = function(self,kind,id,name)
      local new_path = {}
      new_path["kind"] = kind
      if id then
      new_path["id"] = id
      end
      if name and new_path["id"] == nil then
      new_path["name"] = name
      end
      self.key.path[#self.key.path+1] = new_path
    end,
    set_property = function(self,key,value,key_type,index)
      if key_type == "string" or key_type == "boolean" then
        key_type = key_type.."Value"
      elseif key_type == "number" then
 		key_type = "integerValue"
      elseif key_type == "entityValue" then
		value = { properties = value.properties } 
	  end
      self.properties[key] = {}
      self.properties[key][key_type] = value
	  self.properties[key]["excludeFromIndexes"] = index
    end}, { __index = _M })
  return self
end


setmetatable(_M, {__call = construct,__type = "datastore.Entity"})
return _M

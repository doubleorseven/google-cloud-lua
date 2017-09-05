
local _M = {}
local deleted_text = "_deleted-topic_"
_M:Delete()
    self.name = deleted_text..self.name
end

_M:IsDeleted()
    return string.find(self.name,deleted_text)
end

_M:UpdatePushConfig(endpoint,attributes)
    if (endpoint) then
        self.pubshConfig.pushEndpoint = endpoint
    end
    if (attributes and type(attributes) == "table") then
        self.pubshConfig.attributes = attributes
    end
end

function construct(self,name,topic,pc,ads)
  local self = setmetatable({ 
    name = name,
    topic = topic,
    pushConfig = pc or {pushEndpoint = "", attributes = {} },
    ack_deadline_seconds = ads or 10
    }, {__index = _M })
  return self
end

setmetatable(_M, {__call = construct,__type = "pubsub.Subscription"})
return _M

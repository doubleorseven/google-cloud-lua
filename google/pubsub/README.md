# `google-cloud-pubsub-lua`

A library for connecting to [Google Cloud Pub/Sub](https://cloud.google.com/pubsub/) through Lua.

## Usage ( Nginx )


```lua
    server {
        location / {
            content_by_lua_block {
                local OAuth = require("google.core.oauth")
                local PubSub = require("google.pubsub.client")
                local json = require "cjson"
                

                local oauth = OAuth("/path/to/datastoreserviceaccount.json",Datastore.getScopes())
                local pubsub = PubSub(oauth)
                if pubsub then
                end
                --[[ ..... ]]--
            }
        }
    }
```



## Tutorial


### google.datastore.client

Communicates with the Google cloud pubsub API.

```lua
PubSub = require "google.pubsub.client"
```

#### `ps = PubSub(oauth)`

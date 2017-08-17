# `google-cloud-datastore-lua`

A library for connecting to [Google Cloud Datastore](https://cloud.google.com/datastore/) through Lua.

## Usage ( Nginx )


```lua
    server {
        location / {
            content_by_lua_block {
                local OAuth = require("google.core.oauth")
                local Datastore = require("google.datastore.client")
                local json = require "cjson"
                

                local oauth = OAuth("/path/to/datastoreserviceaccount.json",Datastore.getScopes())
                local datastore = Datastore(oauth)
                if datastore then
                  local host = ngx.var.host
                  local domain_data = datastore:Lookup(host)
                  if not domain_data then
                     -- fetch data from my applications and save to datastore
                     domain_data = fetch_data_from_application()
                     
                     -- stage the data in datastore objects
                     local transaction = datastore:BeginTransaction()
                     local entity = transaction:CreateEntity()
                     entity:SetProperty("website_id",tonumber(domain_data.website_id)) -- number
                     entity:SetProperty("website_owner_name",domain_data.website_owner_name) -- string
                     entity:SetProperty("website_use_https",domain_data.website_use_https) -- boolean
                     local redirects = transaction:CreateEntity()
                     for _,obj in pairs(domain_data.website_301_redirectes) do
                       redirects:SetProperty(obj.oldPath,obj.newPath)
                     end
                     entity:SetProperty("website_301_redirectes",redirects,"entityValue") -- nested entity

                     -- set the path for this entity
                     entity:AddPath("Domains",nil,domain_data.website_primary_domain)

                     -- insert operation in a new mutation
                     transaction:Insert(transaction:NewMutation(),entity)

                     -- commit the transaction
                     datastore:Commit(transaction)
                  end
                end
                --[[ ..... ]]--
            }
        }
    }
```



## Tutorial


### google.datastore.client

Communicates with the Google cloud datastore API.

```lua
Datastore = require "google.datastore.client"
```

#### `ds = Datastore(oauth)`

```lua
local ds = Datastore(o)
ds.SetKind("Table")
```

#### `ds:SetKind(kind)`
sets the client's Kind.
this must be done in order to use the client.
use it to change Kinds without setting up a new client.

#### `ds:AllocatedIds(cap)`
allocate ids by the number of `cap`.
return the response from google.
<https://cloud.google.com/datastore/docs/reference/rest/v1/projects/allocateIds>

#### `ds:BeginTransaction(do_transaction)`
begin a new transaction.
set the transaction mode to TRANSACTIONAL by seting `do_transaction`.
returns a transaction Object.
<https://cloud.google.com/datastore/docs/reference/rest/v1/projects/beginTransaction>

#### `ds:Commit(transaction)`
commits a transaction, optionally creating, deleting or modifying some entities.
the `transaction` param is a transaction object.
returns the full response from google.
<https://cloud.google.com/datastore/docs/reference/rest/v1/projects/commit>

#### `ds:Rollback(transaction)`
use this to rollback a transaction by the transaction id.
<https://cloud.google.com/datastore/docs/reference/rest/v1/projects/rollback>

#### `ds:Lookup(entity)`
get an entity by it's key.
the `entity` param is a string.
returns the entity object from the response when found.
<https://cloud.google.com/datastore/docs/reference/rest/v1/projects/lookup>

#### `ds:MultiLookup(entities)`
same as Lookup method but this one excepts an array of strings with entities names.
returns the full response from google.

#### `ds:Query(gql_query,allow_literals)`
queries for entities using gql only.
send your query to `gql_query`.
`allow_literals` is true by default.
returns the full response from google.
<https://cloud.google.com/datastore/docs/reference/rest/v1/projects/runQuery>

### google.datastore.transaction

An object to perform transactions.


```lua
Transaction = require "google.datastore.transaction"
```

#### `transaction = Transaction(project_id,transaction_id,mode)`

```lua
local transaction = Transaction("my_project_id","23423412313","TRANSACTIONAL")
```

#### `transaction:NewMutation()`
init a new mutation table and return it's index.
<https://cloud.google.com/datastore/docs/reference/rest/v1/projects/commit#Mutation>

#### `transaction:CreateEntity(namespace_id)`
use of `namespace_id` is optional
returns a new entity Object.
<https://cloud.google.com/datastore/docs/reference/rest/v1/Entity>

#### `transaction:Insert(index,entity)`
sets a new insert mutation.

#### `transaction:Update(index,entity)`
sets a new update mutation.

#### `transaction:Upsert(index,entity)`
sets a new upsert mutation.

#### `transaction:Delete(index,key)`
sets a new delete muation

#### `transaction:Delete(index,version_id)`
The version of the entity that this mutation is being applied to.


### google.datastore.entity

an entity Object.


```lua
Entity = require "google.datastore.entity"
```

#### `entity = Entity(project_id,namespace_id)`
creates a new entity Object.
the `namespace_id` is optional

```lua
local entity = Entity("my_project_id")
```

#### `entity:AddPath(kind,id,name)`
sets a new path for this entity.
<https://cloud.google.com/datastore/docs/reference/rest/v1/Key#PathElement>

#### `entity:SetProperty(key,value,key_type,index)`
add a property to the entity.
if the type is string,boolean or number there is no need to set key_type.

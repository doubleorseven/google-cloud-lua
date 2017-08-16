# `google-cloud-lua`

the library is a compilation of google cloud services.
The library was inspired and some portions of the code was copied from [Leafo's Google Cloud Storage Repository](https://github.com/leafo/cloud_storage).
The library was build for my custom use in Nginx and it's missing some features to make it complete.
Please feel free to add those missing pieces if you do so. Enjoy!

## getting started:

first thing first is to create a service account for your project.
Go to the APIs console, <https://console.developers.google.com>. Enable
Cloud Storage if you haven't done so already. You may also need to enter
billing information.

Navigate to **Service accounts**, located on the sidebar. Find the **Create
service account** button and click it.


Choose `JSON` for the key type.


```lua
OAuth = require "google.core.oauth"
local fakescope = "https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/fakeservice"
local oauth = OAuth("/path/to/serviceaccount.json",fakescope)

## Reference

### google.core.oauth

Handles OAuth authenticated requests. You must create an OAuth object to authenticate the requests.

```lua
OAuth = require "google.core.oauth"
```

#### `ouath_instance = OAuth(key_path, scope)`

Create a new OAuth object.
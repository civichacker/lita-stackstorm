# lita-stackstorm

**lita-stackstorm** is an adapter for [Lita](https://www.lita.io) that allows your bot to interact with your stackstorm installation via st2api.

## Installation

Add lita-stackstorm to your Lita instance's Gemfile:

``` ruby
gem "lita-stackstorm"
```

## Configuration

### Required

* `url` (String) – The location of the running st2api service.
* `username` (String) – The username used to authenticate with st2api.
* `password` (String) – The password used to authenticate with st2api.

### Optional

* `auth_port` (Integer) – Port used for Authentication. Defaults to `9101`.
* `execution_port` (Integer) – Port for executions. Defaults to `9100`.

### Example

``` ruby
Lita.configure do |config|
    config.handlers.stackstorm.url = "https://st2.example.com"
    config.handlers.stackstorm.username = ENV["ST2_USERNAME"]
    config.handlers.stackstorm.password = ENV["ST2_PASSWORD"]
end
```

## Usage

TODO: Describe the plugin's features and how to use them.

## Notes

### Authentication

assuming standalone mode and defaults. Authentication process starts by:

POST to `/tokens`

```yaml
auth: username:password (in headers?)
port: 9100
headers: |
    content-type: application/json
```

Should returns

```yaml
user
token
expiry
id
metadata
```

### Action aliases

`/actionalias` to `GET` all supported aliases

The payload
```yaml
X-Auth-Token
```

Returns

```json
{
    "action_ref": "packs.info",
        "description": "Get StackStorm pack information via ChatOps",
        "enabled": true,
        "formats": [
            "pack info {{pack}}"
            ],
        "id": "55a691a432ed355e25836f4b",
        "name": "pack_info",
        "pack": "packs",
        "ref": "packs.pack_info"
}
```

### Alias execution
`/aliasexecution` to `POST`

the payload

```yaml
'name': command_name,
'format': format_string,
'command': command,
'user': msg.message.user.name,
'source_channel': msg.message.room,
'notification_channel': env.ST2_CHANNEL
```

Using the example alias from above:

```json
{
    'name': pack_info,
    'format': pack info {{pack}},
    'command': pack info git,
    'user': manas,
    'source_channel': chatops,
    'notification_channel': hubot
}
```

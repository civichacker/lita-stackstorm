# lita-stackstorm

**lita-stackstorm** is an handler for [Lita](https://www.lita.io) that allows your bot to interact with your stackstorm installation via st2api.

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

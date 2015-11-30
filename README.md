# lita-stackstorm [![Gem Version](https://badge.fury.io/rb/lita-stackstorm.svg)](http://badge.fury.io/rb/lita-stackstorm)

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

`st2 list` - lists all chatops aliases from registered packs.

### Executing Actions

Action Aliases require the `!` prefix. For example, in order to run the `packs.info` action when investigating the linux pack, you'll run:

```shell
!pack info linux
```

This handler also provide support for partial commands. For example, suppose you type:

```shell
!pack deploy
```

The handler will return the closest likely matches:

```shell
possible matches:
    pack deploy {{pack}}
    pack deploy {{pack}} from {{repo}}
```

require "spec_helper"

describe Lita::Handlers::Stackstorm, lita_handler: true do
  it { is_expected.to route_command("st2 login").to(:login) }
  it { is_expected.to route_command("st2 list").to(:list) }
  it { is_expected.to route_command("!pack info").to(:call_alias) }
end

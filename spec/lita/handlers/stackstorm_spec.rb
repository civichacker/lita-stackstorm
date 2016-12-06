require "spec_helper"

describe Lita::Handlers::Stackstorm, lita_handler: true do
  let(:token_resp) do
    {
      "token" => "asdf"
    }.to_json
  end

  let(:actionalias_resp) do
    [
      {
        description: "Get StackStorm pack information via ChatOps",
        extra: {},
        ack: {},
        enabled: true,
        name: "pack_info",
        result: {},
        formats: [
          "pack info {{pack}}"
        ],
        action_ref: "packs.info",
        pack: "packs",
        ref: "packs.pack_info",
        id: "583f0fc4e1382364659cc740",
        uid: "action:packs:pack_info"
      }
    ].to_json
  end

  before do
    registry.configure do |config|
      config.handlers.stackstorm.url = "https://st2.example.local"
      config.handlers.stackstorm.username = "dummy_user"
      config.handlers.stackstorm.password = "dummy_pass"
    end

    allow(described_class).to receive(:new).and_return(subject)

    stub_request(:post, "https://st2.example.local:9100/v1/tokens")
      .with(
        headers: {
          "Authorization" => "Basic ZHVtbXlfdXNlcjpkdW1teV9wYXNz"
        }
      )
      .to_return(status: 200, body: token_resp, headers: {})
  end

  it { is_expected.to route_command("st2 login").to(:login) }
  it { is_expected.to route_command("st2 list").to(:list) }
  it { is_expected.to route_command("!pack info").to(:call_alias) }

  it "should reply correctly to 'st2 list'" do
    stub_request(:get, "https://st2.example.local:9101/v1/actionalias")
      .with(
        headers: {
          "Content-Type" => "application/json",
          "X-Auth-Token" => "asdf"
        }
      )
      .to_return(status: 200, body: actionalias_resp, headers: {})

    send_command("st2 list")
    expect(replies.last).to include("pack info {{pack}} -> Get StackStorm pack information via ChatOps")
  end
end

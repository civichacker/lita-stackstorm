require 'json'

module Lita
  module Handlers
    class Stackstorm < Handler
      # insert handler code here

      config :url, required: true
      config :username, required: true
      config :password, required: true

      class << self
        attr_accessor :token, :expires
      end

      def self.config(config)
        self.token = nil
        self.expires = nil
      end

      route /^st2 login/, :login, command: false, help: { "st2 login" => "login with st2-api" }
      route /^st2 list/, :list, command: false, help: { "st2 list" => "list available st2 chatops commands" }

      def authenticate
        resp = http.post("#{config.url}:9100/v1/tokens") do |req|
          req.body = {}
          req.headers['Authorization'] = http.set_authorization_header(:basic_auth, config.username, config.password)
        end
        self.class.token = JSON.parse(resp.body)['token']
        self.class.expires = JSON.parse(resp.body)['expiry']
        resp
      end

      def list(msg)
        if expired
          authenticate
        end
        s = make_request(":9101/v1/actionalias", "")
        if JSON.parse(s.body).empty?
          msg.reply "No Action Aliases Registered"
        else
          msg.reply "hey #{s.status} #{s.body}"
        end
      end

      def login(msg)
        http_resp = authenticate
        if ![200, 201, 280].index(http_resp.status).nil?
          msg.reply "login successful\ntoken: #{self.class.token}"
        elsif http_resp.status == 500
          msg.reply "#{http_resp.status}: login failed!!"
        else
          msg.reply "#{http_resp.status}: login failed!!"
        end
      end

      def expired
        self.class.token.nil? || Time.now >= Time.parse(self.class.expires)
      end

      def make_request(path, body)
        resp = http.get("#{config.url}#{path}") do |req|
          req.body = {}
          req.headers = headers
          req.body = body
        end
        resp
      end

      def headers
        headers = {}
        headers['Content-Type'] = 'application/json'
        headers['X-Auth-Token'] = "#{self.class.token}"
        headers
      end

      Lita.register_handler(self)
    end
  end
end

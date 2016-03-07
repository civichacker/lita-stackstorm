require 'json'

class Array
  def swap!(a,b)
    self[a], self[b] = self[b], self[a]
    self
  end
end



module Lita
  module Handlers
    class Stackstorm < Handler
      # insert handler code here

      config :url, required: true
      config :username, required: true
      config :password, required: true
      config :auth_port, required: false, default: 9100
      config :execution_port, required: false, default: 9101

      class << self
        attr_accessor :token, :expires
      end

      def self.config(config)
        self.token = nil
        self.expires = nil
      end

      route /^st2 login$/, :login, command: false, help: { "st2 login" => "login with st2-api" }
      route /^st2 (ls|aliases|list)$/, :list, command: false, help: { "st2 list" => "list available st2 chatops commands" }

      route /^!(.*)$/, :call_alias, command: false, help: {}

      def auth_builder
        if Integer(config.auth_port) == 443 and config.url.start_with?('https')
          "#{config.url}/auth"
        else
          "#{config.url}:#{config.auth_port}/v1"
        end
      end

      def url_builder
        if Integer(config.execution_port) == 443 and config.url.start_with?('https')
          "#{config.url}/api"
        else
          "#{config.url}:#{config.execution_port}/v1"
        end
      end

      def authenticate
        resp = http.post("#{auth_builder()}/tokens") do |req|
          req.body = {}
          req.headers['Authorization'] = http.set_authorization_header(:basic_auth, config.username, config.password)
        end
        self.class.token = JSON.parse(resp.body)['token']
        self.class.expires = JSON.parse(resp.body)['expiry']
        resp
      end

      def call_alias(msg)
        if expired
          authenticate
        end
        command_array = msg.matches.flatten.first.split
        command_set = Set.new(command_array)

        candidates = redis.scan_each(:match => "#{command_array[0..1].join(' ')}*")

        candidates_set = Set.new(candidates)
        h = candidates_set.classify do |s|
          st = Set.new(s.split /(?<=})\s|\s(?={)|\b\s\b/)
          (st - command_set).length
        end

        if h[h.keys.min].length == 1
          payload = {
            name: command_array.swap!(command_array.length-2,command_array.length-1).join('_'),
            format: h[h.keys.min].to_a.join(" "),
            command: msg.matches.flatten.first,
            user: msg.user.name,
            source_channel: 'chatops',
            notification_channel: 'lita'
          }
          s = make_post_request("/aliasexecution", payload)
          j = JSON.parse(s.body)
          if s.success?
            msg.reply "Got it! Details available at #{config.url}/#/history/#{j['execution']['id']}/general"
          else
            msg.reply "Execution failed with message: #{j['faultstring']}"
          end
        elsif h[h.keys.min].length > 1
          response_text = "possible matches:"
          h[h.keys.min].each do |match|
            response_text+= "\n\t#{match}"
          end
          msg.reply response_text
        else
          msg.reply "Failed! No Aliases Found..."
        end
      end

      def list(msg)
        if expired
          authenticate
        end
        s = make_request("/actionalias", "")
        if JSON.parse(s.body).empty?
          msg.reply "No Action Aliases Registered"
        else
          j = JSON.parse(s.body)
          a = ""
          j.take_while{|i| i['enabled'] }.each do |command|
            command['formats'].each do |format|
              redis.set(format, command['action_ref'])
              a+= "#{format} -> #{command['action_ref']}\n"
            end
          end
          msg.reply a
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
        resp = http.get("#{url_builder()}#{path}") do |req|
          req.headers = headers
          req.body = body.to_json if not body.empty?
        end
        resp
      end

      def make_post_request(path, body)
        resp = http.post("#{url_builder()}#{path}") do |req|
          req.body = {}
          req.headers = headers
          req.body = body.to_json
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

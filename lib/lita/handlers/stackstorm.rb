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

      route /^st2/i, :action, command: false, help: {
        '!st2 action list' => 'Get the list of actions.',
        '!st2 action get' => 'Get individual action.',
        '!st2 action create' => 'Create a new action.',
        '!st2 action update' => 'Update an existing action.',
        '!st2 action delete' => 'Delete an existing action.',
        '!st2 action execute' => 'A command to invoke an action manually.',

        }

      def authenticate
        conn = http(:url => "http://example.com")
        conn.port = 9100
        conn.basic_auth('testu', 'testp')
        response = conn.post('/tokens')
        #self.class.expires = JSON.parse(response.body)['return'][0]['expirey']
        #self.class.token = JSON.parse(resp.body)['return'][0]['token']
        response
      end

        def action(msg)
          if expired
            authenticate
          end
          msg.matches.flatten.first
          msg.reply "yo!"
        end


        def expired
          self.class.token.nil? || Time.now >= Time.at(self.class.expires)
        end

        def port
          config.port ||= 9100
        end
    end

    Lita.register_handler(Stackstorm)
  end
end

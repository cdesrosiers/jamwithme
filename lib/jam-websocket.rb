require 'em-websocket'
ENV["MONGOID_ENV"] = "development"
require 'mongoid'

# simplified user model for websocket use
class User
  include Mongoid::Document
 
  field :u, as: :username,        type: String
  field :r, as: :remember_token,  type: String

  attr_readonly :username, :remember_token
  
  index({ username: 1 }, unique: true)
  index({ remember_token: 1 })
end

class JamServer

  AUTH_TOKEN_REGEX = /(?<=remember_token=)[^;]+(?=;)?/

  
  class EventMachine::WebSocket::Connection 
    attr_accessor :partner
    attr_accessor :username
    attr_accessor :instrument
  end
  
  def initialize
    @partner_queue = []
    @open_connections = 0
    Mongoid.load! File.expand_path('../mongoid.yml', __FILE__)
    p "Server initialized"
  end

  def run
    EventMachine::WebSocket.start(:host => "192.168.1.2", :port => 8080) do |ws|
      ws.onopen do
        remember_token = AUTH_TOKEN_REGEX.match(ws.request['cookie'])[0]
        
        user = User.find_by(remember_token: remember_token)
        ws.username = user.username

        p "New connection from #{ws.username}"

        # check for other unpartnered sockets
        partner = @partner_queue.delete_at(0)
        if partner
          ws.instrument = 'bass'
          ws.send("instrument: #{ws.instrument}")
          ws.send("Your new partner is #{partner.username}.")
          ws.partner = partner
          partner.partner = ws
          partner.send("instrument: #{partner.instrument}")
          partner.send("Your new partner is #{ws.username}.")
          p "New partnership between #{ws.username} and #{partner.username}."  
        else
          ws.instrument = 'guitar'
          ws.send('Waiting for a partner...')
          @partner_queue.push ws
          p "#{ws.username} is waiting for a partner..."
        end

        @open_connections += 1
        p "Open connections: #{@open_connections}"
      end

      ws.onmessage do |msg|
        if ws.partner
          p "#{ws.username} sends '#{msg}' to #{ws.partner.username}"
          ws.partner.send(check_msg(msg))
        end
      end

      ws.onclose do
        unless ws.partner.nil?
          ws.partner.send('Your partner has disconnected. We are closing your connection.')

          partner_username = ws.partner.username
          ws.partner.partner = nil
          ws.partner.close_connection_after_writing
          ws.partner = nil

        end
        @open_connections -= 1
        p "#{ws.username} has disconnected"
        p "Open connections: #{@open_connections}"
      end
    end
  end

  def check_msg(msg)
    "#{msg}"
  end

  def test
    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
      ws.onopen do 
        p "WebSocket opened"
        ws.send "Hello Client! Your partner is #{ws.partner}"
      end
      ws.onmessage do |msg| 
        if msg == "PAIRUP"
          p "Looking for partner..."
          ws.send "Let's find a partner for you..."
          # connect to database and set 
        end
      end
      ws.onclose   { puts "WebSocket closed" }
    end
  end
end


server = JamServer.new
server.run

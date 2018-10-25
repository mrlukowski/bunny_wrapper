#!/usr/bin/env ruby
require "rubygems"
require "bunny"
require "json"
require "./env"

# Returns a connection instance
conn = Bunny.new(
  ENV["CLOUDAMQP_URL"],
  :tls => true,
  :port => 5671,
  :tls_cert => "cert.pem",
  :tls_key => "key.pem",
  :tls_ca_certificates => ["cacert.pem"],
  :verify_peer => false,
)

conn.start
ch = conn.create_channel
q = ch.queue("examplequeue", :durable => true)

x = ch.direct("example.exchange", :durable => true)
q.bind(x, :routing_key => "process")

##example publisher just for sending  cople messagess

for key in [1, 2, 3, 4, 5, 6]
  information_message = "{\"email#{key}\": \"example@mail.com\",\"name\": \"name\",\"size\": \"size\"}"
  x.publish(information_message,
            :timestamp => Time.now.to_i,
            :routing_key => "process")

  sleep 1.0
  puts "wyslano #{key}"
end

conn.close

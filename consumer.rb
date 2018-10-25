#!/usr/bin/env ruby
require "rubygems"
require "bunny"
require "json"
require "./env"

conn = Bunny.new(
  ENV["CLOUDAMQP_URL"],
  :tls => true,
  :port => 5671,
  :tls_cert => "cert.pem",
  :tls_key => "key.pem",
  :tls_ca_certificates => ["cacert.pem"],
  :verify_peer => false,
)
quit = false
consumer_queued = false
conn.start

consumer = Thread.new do
  puts "consumer start"
  ch = conn.create_channel

  q = ch.queue("examplequeue", :durable => true)
  consumer_queued = true
  q.subscribe do |delivery_info, properties, payload|
    puts " received: #{payload}, routing key is #{delivery_info.routing_key}"
    $stdout.flush
    ## here you can  exec a multiple thread  commands in php example
    spawn "cd /home/account/workspace; php bin/console mycommand:symfonyExample --parameters "
  end

  sleep 10 while !quit
  ch.close
  puts "consumer done"
end
## time is for example
sleep 20 while !consumer_queued
quit = true
consumer.join

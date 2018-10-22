#!/usr/bin/env ruby
require "rubygems"
require "bunny"
require "json"
require "./env"

conn = Bunny.new ENV["CLOUDAMQP_URL"]
quit = false
consumer_queued = false
conn.start

consumer = Thread.new do
  puts "consumer start"
  ch = conn.create_channel

  q = ch.queue("examplequeue", :durable => true)
  consumer_queued = true
  q.subscribe do |delivery_info, properties, payload|
    puts " otrzymano: #{payload}, routing key is #{delivery_info.routing_key}"
    $stdout.flush
  end
  sleep 1 while !quit
  ch.close
  puts "consumer done"
end
sleep 0.125 while !consumer_queued
quit = true
consumer.join

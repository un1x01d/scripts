#!/usr/bin/ruby

require 'rb-inotify'

notifier = INotify::Notifier.new

notifier.watch("/tmp", :moved_to, :create) do |event|
  puts "#{event.name} is now in /tmp!"
end


notifier.run

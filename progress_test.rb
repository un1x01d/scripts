#!/usr/bin/ruby

require 'ruby-progressbar'


progressbar  = ProgressBar.create(:format => '%a |%b>>%i| %p%% %t', :starting_at => 10)

10.times do
  sleep 0.1
  progressbar.increment
end


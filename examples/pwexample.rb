# Copyright (C) 2012 Peter Allin <peter@peca.dk>
#
# This file is part of Watchful.
#
#  Watchful is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  Watchful is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Watchful.  If not, see <http://www.gnu.org/licenses/>.

require 'driver'
require 'ping_watcher'
require 'thread'

Thread.abort_on_exception = true

class Observer
  def initialize
    @queue = Queue.new
    @watchers = {}
    @hosts = {}
  end

  def start
    Thread.new do
      while true do
        process_next_message
      end
    end
    return self
  end

  def process_next_message
    msg = @queue.pop
    msg.execute self
  end

  def process_update(watcher, state)
    host = @watchers[watcher][:host]
    watcher_type = @watchers[watcher][:type]
    @hosts[host][watcher_type] = state
    puts @hosts.inspect
    puts
  end
  
  class Update
    def initialize(watcher, state)
      @watcher = watcher
      @state = state
    end

    def execute(observer)
      observer.process_update(@watcher, @state)
    end
  end

  def register_host_watcher(watcher, host)
    watcher_type = watcher.kind
    @watchers[watcher] = { :type => watcher_type, :host => host }
    @hosts[host] = {} if not @hosts[host]
    @hosts[host][watcher_type] = :unknown
  end
  
  def up(watcher)
    @queue.push Update.new(watcher, :up)
  end

  def down(watcher)
    @queue.push Update.new(watcher, :down)
  end

end

o = Observer.new.start
watchers = [
            Driver.new(PingWatcher.new("rendertest", o), 1),
            Driver.new(PingWatcher.new("zinc", o), 1.5),
            Driver.new(PingWatcher.new("silver", o), 2)
           ]

watchers.each { |w| w.start; sleep 0.5 }
sleep 2000
watchers.each { |w| w.stop }

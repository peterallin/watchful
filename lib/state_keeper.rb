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

class StateKeeper
  class WatcherUpdate
    def initialize(watcher, new_state)
      @watcher = watcher
      @new_state = new_state
    end

    def execute(state_keeper)
      state_keeper.set_state(@watcher, @new_state)
    end
  end
  
  def initialize
    @queue = Queue.new
    @watchers = {}
    @states = {}
    @viewers = []
  end
  
  def register_host_watcher(watcher, host)
    @watchers[host] = [] if not @watchers[host]
    @watchers[host] = watcher  ### FIXME: Should be "push" not "="
    @states[host] = {} if not @states[host] 
    @states[host][watcher] = :unknown
  end

  def register_state_viewer(viewer)
    @viewers.push viewer
  end  

  def hosts_watched
    @watchers.keys
  end

  def states(host)
    @states[host]
  end

  def finished?
    false
  end

  def step
    return if @queue.length == 0
    @queue.pop.execute(self)
  end

  def set_state(watcher, state)
    if @states[watcher.host][watcher] != state then
      @states[watcher.host][watcher] = state
      @viewers.each { |v| v.update }
    end
  end
  
  def up(watcher)
    @queue.push WatcherUpdate.new(watcher, :up)
  end

  def down(watcher)
    @queue.push WatcherUpdate.new(watcher, :down)
  end

end

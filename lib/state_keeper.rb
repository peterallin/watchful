class StateKeeper
  def initialize
    @watchers = {}
    @states = {}
  end
  
  def register(watcher, host)
    @watchers[host] = [] if not @watchers[host]
    @watchers[host] = watcher
    @states[host] = {} if not @states[host]
    @states[host][watcher] = nil
  end

  def hosts_watched
    @watchers.keys
  end

  def up(watcher)
    set_state(watcher, :up)
  end

  def down(watcher)
    set_state(watcher, :down)
  end

  def states(host)
    @states[host]
  end

  private

  def set_state(watcher, state)
    @states[watcher.host][watcher] = state
  end
end

class StateKeeper
  def initialize
    @watchers = {}
    @states = {}
    @viewers = []
  end
  
  def register_host_watcher(watcher, host)
    @watchers[host] = [] if not @watchers[host]
    @watchers[host] = watcher  ### FIXME: Should be "push" not "="
    @states[host] = {} if not @states[host] 
    @states[host][watcher] = nil
  end

  def register_state_viewer(viewer)
    @viewers.push viewer
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
    if @states[watcher.host][watcher] != state then
      @states[watcher.host][watcher] = state
      @viewers.each { |v| v.update }
    end
  end
  
end

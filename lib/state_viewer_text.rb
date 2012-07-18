class StateViewerText
  def initialize(state)
    @state = state
    @state.register_state_viewer(self)
  end

  def update
    print_state
  end

  private
  
  def print_state
    host_text_states = []
    @state.hosts_watched.each do |host|
      host_text_state = "#{host.name}:\n"
      states = @state.states(host) 
      states.keys.sort { |a,b| a.kind <=> b.kind }.each do |watcher|
        host_text_state << "  #{watcher.kind}: #{watcher.status.to_s.capitalize}\n"
      end
      host_text_states.push host_text_state
    end
    puts host_text_states.join "\n"
  end
end

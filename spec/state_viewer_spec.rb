require 'state_viewer_text'
require 'capture'
require 'host'
require 'state_keeper'

class TestWatcherSVS
  attr_reader :host, :kind, :state, :status
  def initialize(kind, host, state, watcher_status)
    @kind = kind
    @host = host
    @state = state
    @state.register_host_watcher(self, host)
    @status = watcher_status
  end
end

class TestStateSVS
  attr_reader :viewers
  def initialize(*hosts)
    @viewers = []
    @hosts = hosts
    @watchers = {}
  end
  
  def hosts_watched
    @hosts
  end

  def states(host)
    return {} if not @watchers[host]
    result = {}
    @watchers[host].each do |w|
      result[w] = w.state
    end
    return result
  end
  
  def register_state_viewer(sv)
    @viewers.push sv
  end

  def register_host_watcher(watcher, host)
    @watchers[host] = [] if not @watchers[host]
    @watchers[host].push watcher
  end

end

describe StateViewerText do
  it "registers with a state" do
    state = TestStateSVS.new
    state_viewer = StateViewerText.new(state)
    state.viewers.should eq([state_viewer])
  end

  it "prints status for each watched host" do
    host1 = Host.new("Host1")
    host2 = Host.new("Host2")
    state = TestStateSVS.new(host1, host2)
    state_viewer = StateViewerText.new(state)
    watcher1_1 = TestWatcherSVS.new("Watcher1", host1, state, :up)
    watcher2_1 = TestWatcherSVS.new("Watcher2", host1, state, :up)
    watcher3_1 = TestWatcherSVS.new("Watcher3", host1, state, :down)
    watcher1_2 = TestWatcherSVS.new("Watcher1", host2, state, :up)
    watcher4_2 = TestWatcherSVS.new("Watcher4", host2, state, :down)
    state_text = capture(:stdout) { state_viewer.update }
    expected_state_text = <<eos
Host1:
  Watcher1: Up
  Watcher2: Up
  Watcher3: Down

Host2:
  Watcher1: Up
  Watcher4: Down
eos
    state_text.should eq expected_state_text
  end
  
end



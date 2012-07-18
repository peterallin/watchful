require 'state_keeper'
require 'ping_watcher'
require 'host'

class TestWatcher
  attr_reader :host
  
  def initialize(host, observer)
    @host = host
    @observer = observer
    @observer.register_host_watcher(self, host)
  end
  
  def up
    @observer.up(self)
  end
  
  def down
    @observer.down(self)
  end
  
  def kind
    "test"
  end
end

class TestPinger
  def initialize
    @state = false
  end
  
  def ping(host)
    @state
  end
  
  def set_up
    @state = true
  end
  
  def set_down
    @state = false
  end

  def make_method
    self.method(:ping)
  end
end

describe StateKeeper do
  it "maintains a list of hosts being watched" do
    state = StateKeeper.new

    host1 = Host.new("foo")
    host2 = Host.new("bar")
    host3 = Host.new("baz")
    
    ping_watcher = PingWatcher.new(host1, state)
    ping_watcher = PingWatcher.new(host2, state)
    ping_watcher = PingWatcher.new(host3, state)
    
    state.hosts_watched.length.should eq 3
    state.hosts_watched.should include host1
    state.hosts_watched.should include host2
    state.hosts_watched.should include host3
  end
  
  it "can give a list of the state of each watcher for a host" do
    state = StateKeeper.new

    host1 = Host.new("foo")
    host2 = Host.new("bar")
    host1_ping = TestPinger.new
    host2_ping = TestPinger.new

    pw_host1 = PingWatcher.new(host1, state, host1_ping.make_method)
    pw_host2 = PingWatcher.new(host2, state, host2_ping.make_method)
    tw_host1 = TestWatcher.new(host1, state)

    
    host1_ping.set_up
    host2_ping.set_down
    [ pw_host1, pw_host2 ].each { |w| w.step }
    tw_host1.down

    host1_states = state.states(host1)
    host1_states.keys.length.should eq(2)
    host1_states.keys.should include(pw_host1)
    host1_states[pw_host1].should eq(:up)
    host1_states[tw_host1].should eq(:down)

    tw_host1.up
    host1_states = state.states(host1)
    host1_states.keys.length.should eq(2)
    host1_states.keys.should include(pw_host1)
    host1_states[pw_host1].should eq(:up)
    host1_states[tw_host1].should eq(:up)

    host2_states = state.states(host2)
    host2_states.keys.length.should eq(1)
    host2_states.keys.should include(pw_host2)
    host2_states[pw_host2].should eq(:down)
  end

  it "tells viewers when the state changes" do
    class TestStateViewer
      attr_reader :times_updated
      def initialize
        @times_updated = 0
      end
      
      def update
        @times_updated = @times_updated + 1
      end
    end

    state = StateKeeper.new
    state_viewer = TestStateViewer.new
    state.register_state_viewer state_viewer
    host = Object.new
    tw = TestWatcher.new(host, state)
    tw.up
    state_viewer.times_updated.should eq(1)
    tw.up
    state_viewer.times_updated.should eq(1)
    tw.down
    state_viewer.times_updated.should eq(2)
    tw.down
    state_viewer.times_updated.should eq(2)
    tw.up
    state_viewer.times_updated.should eq(3)
  end
end

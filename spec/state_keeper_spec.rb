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

require 'state_keeper'
require 'ping_watcher'
require 'host'

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
    host1_ping = double("Host1Ping")
    host1_ping.should_receive(:pingecho).and_return(true)
    host2_ping = double("Host2Ping")
    host2_ping.should_receive(:pingecho).and_return(false)

    pw_host1 = PingWatcher.new(host1, state, host1_ping.method(:pingecho))
    pw_host2 = PingWatcher.new(host2, state, host2_ping.method(:pingecho))
    tw_host1 = double("watcher")
    tw_host1.stub(:host).and_return(host1)
    
    [ pw_host1, pw_host2 ].each { |w| w.step; state.step }
    state.down(tw_host1)
    state.step
    
    host1_states = state.states(host1)
    host1_states.keys.length.should eq(2)
    host1_states.keys.should include(pw_host1)
    host1_states[pw_host1].should eq(:up)
    host1_states[tw_host1].should eq(:down)

    state.up(tw_host1)
    state.step
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

  it "tells viewers when the state of a watcher changes" do
    state = StateKeeper.new
    state_viewer = double("StateViewer")
    state_viewer.should_receive(:update).exactly(5).times
    state.register_state_viewer state_viewer
    host = double("Host")
    tw1 = double("Watcher1")
    tw1.stub(:host).and_return(host)
    tw2 = double("Watcher2")
    tw2.stub(:host).and_return(host)
    state.register_host_watcher(tw1, host)
    state.register_host_watcher(tw2, host)
    
    state.up(tw1); state.step
    state.up(tw1); state.step
    state.down(tw1); state.step
    state.down(tw1); state.step
    state.up(tw1); state.step
    state.up(tw2); state.step
    state.up(tw2); state.step
    state.down(tw2); state.step
  end

  it "handles all available events in each step" do
    state = StateKeeper.new
    state_viewer = double("StateViewer")
    state_viewer.should_receive(:update).exactly(5).times
    state.register_state_viewer state_viewer
    host = double("Host")
    tw1 = double("Watcher1")
    tw1.stub(:host).and_return(host)
    tw2 = double("Watcher2")
    tw2.stub(:host).and_return(host)
    state.register_host_watcher(tw1, host)
    state.register_host_watcher(tw2, host)
    
    state.up(tw1)
    state.up(tw1)
    state.down(tw1)
    state.down(tw1)
    state.up(tw1)
    state.up(tw2)
    state.up(tw2)
    state.down(tw2)
    state.step
  end

  it "can tell if any watchers have unknown state" do
    state = StateKeeper.new
    host = Host.new("testhost")
    watcher1 = double("Watcher1")
    watcher1.stub(:host).and_return(host)
    watcher2 = double("Watcher2")
    watcher2.stub(:host).and_return(host)
    state.register_host_watcher(watcher1, host)
    state.register_host_watcher(watcher2, host)
    state.any_unknown?.should eq(true)
    state.set_state(watcher1, :up)
    state.any_unknown?.should eq(true)
    state.set_state(watcher2, :up)
    state.any_unknown?.should eq(false)    
  end
  
  it "is not finished" do
    StateKeeper.new.finished?.should eq(false)
  end
end

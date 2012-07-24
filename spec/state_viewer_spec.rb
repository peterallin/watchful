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

require 'state_viewer_text'
require 'capture'
require 'host'
require 'state_keeper'

describe StateViewerText do

  it "registers with a state" do
    state = double("StateKeeper")
    state.should_receive(:register_state_viewer).with(kind_of(StateViewerText))
    state_viewer = StateViewerText.new(state)
  end

  it "prints status for each watched host" do
    host1 = double("Host1", :name => "Host1")
    host2 = double("Host2", :name => "Host2")
    w1 = double("Watcher1", :kind => "Watcher1")
    w2 = double("Watcher2", :kind => "Watcher2")
    w3 = double("Watcher3", :kind => "Watcher3")
    w4 = double("Watcher4", :kind => "Watcher4")
    state = double("StateKeeper")
    state.should_receive(:register_state_viewer)
    state.should_receive(:hosts_watched).and_return [host1, host2]
    state.should_receive(:states).with(host1).and_return(w1 => :up, w2 => :up, w3 => :down)
    state.should_receive(:states).with(host2).and_return(w1 => :up, w4 => :down)

    state_viewer = StateViewerText.new(state)
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



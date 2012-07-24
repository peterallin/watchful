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

require 'ping_watcher'

describe PingWatcher do

  it "is of the 'ping' kind" do
    test_observer = double("Observer")
    test_observer.stub(:register_host_watcher)
    PingWatcher.new(nil, test_observer).kind.should eq "ping"
  end
  
  it "is not finished" do
    test_observer = double("Observer")
    test_observer.stub(:register_host_watcher)
    PingWatcher.new(nil, test_observer).finished?.should eq(false)
  end

  it "registers with an observer" do
    test_host = double("Host")
    observer = double("Observer")
    observer.should_receive(:register_host_watcher).with(kind_of(PingWatcher), test_host)
    pw = PingWatcher.new(test_host, observer)
  end

  it "tells the observer when the subject is 'up'" do
    observer = double("Observer")
    observer.stub(:register_host_watcher)
    pw = PingWatcher.new(nil, observer, Proc.new { |h| true })
    observer.should_receive(:up).with(pw)
    pw.step
  end

  it "tells the observer when the subject is 'down'" do
    observer = double("Observer")
    observer.stub(:register_host_watcher)
    pw = PingWatcher.new(nil, observer, Proc.new { |h| false })
    observer.should_receive(:down).with(pw)
    pw.step
  end

  it "pings the given host" do
    host = double("Host")
    observer = double("Observer")
    observer.stub(:register_host_watcher)
    observer.stub(:down)
    ping = double("Ping")
    ping.should_receive(:pingecho).with(host)
    pw = PingWatcher.new(host, observer, ping.method(:pingecho))
    pw.step
  end

  it "pings once per step" do
    ping = double("Ping")
    ping.should_receive(:pingecho).exactly(10).times
    observer = double("Observer")
    observer.stub(:register_host_watcher)
    observer.stub(:down)
    
    pw = PingWatcher.new(nil, observer, ping.method(:pingecho))

    (1..10).each { pw.step }
  end
end

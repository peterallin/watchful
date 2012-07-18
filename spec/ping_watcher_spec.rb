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

class TestObserver
  attr_reader :watchers, :ups, :downs

  def initialize
    @watchers = []
    @ups = []
    @downs = []
  end

  def register_host_watcher(subject, host)
    @watchers.push subject
  end

  def up(watcher)
    @ups.push watcher
  end

  def down(watcher)
    @downs.push watcher
  end
end

describe PingWatcher do

  it "is on the 'ping' kind" do
    PingWatcher.new(nil, TestObserver.new).kind.should eq "ping"
  end
  
  it "never finishes" do
    PingWatcher.new(nil, TestObserver.new).finished?.should eq(false)
  end

  it "registers with an observer" do
    observer = TestObserver.new
    observer.watchers.length.should eq(0)
    pw = PingWatcher.new(nil, observer)
    observer.watchers.length.should eq(1)
    observer.watchers[0].should be(pw)
  end

  it "tells the observer when the subject is 'up'" do
    observer = TestObserver.new
    observer.ups.size.should eq(0)

    pw = PingWatcher.new(nil, observer, Proc.new { |h| true })
    pw.step

    observer.ups.size.should eq(1)
  end

  it "tells the observer when the subject is 'down'" do
    observer = TestObserver.new
    observer.downs.size.should eq(0)

    pw = PingWatcher.new(nil, observer, Proc.new { |h| false })
    pw.step

    observer.downs.size.should eq(1)
  end

  it "pings the given host" do
    class TestPing
      attr_reader :last_host
      def pingecho(host)
        @last_host = host
      end
    end
    
    host = Object.new
    observer = TestObserver.new
    ping = TestPing.new
    pw = PingWatcher.new(host, observer, ping.method(:pingecho))
    pw.step
    ping.last_host.should be(host)
  end

  it "pings once per step" do
    class TestPing
      attr_reader :count
      def initialize
        @count = 0
      end
      def pingecho(host)
        @count = @count + 1
      end
    end
    ping = TestPing.new
    observer = TestObserver.new
    pw = PingWatcher.new(nil, observer, ping.method(:pingecho))

    (1..10).each { pw.step }
    ping.count.should eq(10)
  end
end

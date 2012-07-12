require 'ping_watcher'

class TestObserver
  attr_reader :watchers, :ups, :downs

  def initialize
    @watchers = []
    @ups = []
    @downs = []
  end

  def register(subject, watcher_type, host)
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
end

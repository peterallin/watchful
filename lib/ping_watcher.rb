require 'ping'
require 'thread'

class PingWatcher
  def initialize(host, observer, pingproc = Ping.method(:pingecho))
    @host = host
    @observer = observer
    @observer.register(self, 'ping', host)
    @pingproc = pingproc
  end

  def finished?
    false
  end
  
  def step
    up = @pingproc.call @host
    if up
      @observer.up self
    else
      @observer.down self
    end
  end
  
end


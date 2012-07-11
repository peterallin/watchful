require 'ping'
require 'thread'

class PingWatcher
  def initialize(host, observer)
    @host = host
    @observer = observer
    @observer.register(self, 'ping', host)
  end

  def finished?
    false
  end
  
  def step
    up = Ping.pingecho @host
    if up
      @observer.up self
    else
      @observer.down self
    end
  end
  
end


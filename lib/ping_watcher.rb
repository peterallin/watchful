require 'ping'
require 'thread'

class PingWatcher
  attr_reader :host
  
  def initialize(host, observer, pingproc = Ping.method(:pingecho))
    @host = host
    @observer = observer
    @observer.register(self, host)
    @pingproc = pingproc
  end

  def kind
    'ping'
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

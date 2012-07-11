require 'thread'

class Driver
  def initialize(drivee, pause_seconds)
    @drivee = drivee
    @pause_seconds = pause_seconds
  end
  
  def stop
    @thread.kill
  end

  def start
    @thread = Thread.new do
      while not @drivee.finished? do
        @drivee.step
        sleep @pause_seconds
      end
    end
  end
end

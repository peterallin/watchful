require 'thread'

class Driver
  def initialize(drivee, pause_seconds, thread_class = Thread, sleep_method = method(:sleep))
    @thread_class = thread_class
    @drivee = drivee
    @pause_seconds = pause_seconds
    @sleep = sleep_method
  end
  
  def stop
    @thread.kill
  end

  def start
    @thread = @thread_class.new do
      while not @drivee.finished? do
        @drivee.step
        @sleep.call @pause_seconds
      end
    end
  end
end

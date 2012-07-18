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

require 'driver'

class CountingTestThread
  @@instances = 0

  def initialize
    @@instances = @@instances + 1
  end

  def kill
    @@instances = @@instances - 1
  end
  
  def self.instances
    @@instances
  end
end

class DrivingTestThread
  def initialize(&block)
    @block = block
    block.call
  end
end

class TestDrivee
  attr_reader :steps
  
  def initialize(max_steps)
    @steps = 0
    @max_steps = max_steps
  end

  def step
    @steps = @steps + 1
  end
  
  def finished?
    @max_steps <=@steps
  end
end

class Sleeper
  attr_reader :seconds_slept
  def initialize
    @seconds_slept = 0
  end

  def sleep(s)
    @seconds_slept = @seconds_slept + s
  end
end

describe Driver do
  it "creates a thread when started" do
    orig_instances = CountingTestThread.instances 
    driver = Driver.new(nil, nil, CountingTestThread)
    driver.start
    CountingTestThread.instances.should eq(1 + orig_instances)
  end

  it "destroys the thread when stopped" do
    orig_instances = CountingTestThread.instances 
    driver = Driver.new(nil, nil, CountingTestThread)
    driver.start
    driver.stop
    CountingTestThread.instances.should eq(orig_instances)
  end

  it "steps the drivee until drivee is finished" do
    drivee = TestDrivee.new 10
    driver = Driver.new(drivee, 0, DrivingTestThread)
    driver.start
    drivee.steps.should eq 10
  end

  it "sleeps a specified number of seconds for each step" do
    num_steps = 10
    pause_secs = 2
    sleeper = Sleeper.new
    drivee = TestDrivee.new num_steps
    driver = Driver.new(drivee, pause_secs, DrivingTestThread, sleeper.method(:sleep))
    driver.start
    sleeper.seconds_slept.should eq(num_steps*pause_secs)
  end

end


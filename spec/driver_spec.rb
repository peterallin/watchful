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

describe Driver do
  it "creates a thread when started" do
    thread_class = double("Thread")
    thread_class.should_receive(:new)
    driver = Driver.new(nil, nil, thread_class)
    driver.start
  end

  it "destroys the thread when stopped" do
    thread_object = double("thread_object")
    thread_object.should_receive(:kill)
    thread_class = double("Thread")
    thread_class.should_receive(:new).and_return(thread_object)
    
    driver = Driver.new(nil, nil, thread_class)
    driver.start
    driver.stop
  end

  it "steps the drivee until drivee is finished" do
    drivee = double("drivee")
    drivee.should_receive(:finished?).and_return(*([false]*10+[true]))
    drivee.should_receive(:step).exactly(10).times
    thread_class = double("Thread")
    thread_class.should_receive(:new).and_yield
    driver = Driver.new(drivee, 0, thread_class)
    driver.start
  end
  
  it "sleeps a specified number of seconds for each step" do
    num_steps = 10
    pause_secs = 2
    sleeper = double("sleeper")
    sleeper.should_receive(:sleep).with(pause_secs).exactly(num_steps).times
    
    drivee = double("drivee")
    drivee.should_receive(:finished?).and_return(*([false]*num_steps+[true]))
    drivee.should_receive(:step).any_number_of_times
    thread_class = double("Thread")
    thread_class.should_receive(:new).and_yield
    driver = Driver.new(drivee, pause_secs, thread_class, sleeper.method(:sleep))
    driver.start
  end

end


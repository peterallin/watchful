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

  def join
    @thread.join
  end
end

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

require 'ping'
require 'thread'

class PingWatcher
  attr_reader :host
  
  def initialize(host, observer, pingproc = Ping.method(:pingecho))
    @host = host
    @observer = observer
    @observer.register_host_watcher(self, host)
    @pingproc = pingproc
  end

  def kind
    'ping'
  end
  
  def finished?
    false
  end
  
  def step
    up = @pingproc.call @host.name
    if up
      @observer.up self
    else
      @observer.down self
    end
  end
  
end

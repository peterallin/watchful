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

require 'terminfo'

class StateViewerMultiPing
    def initialize(state, term_info = TermInfo)
    @term_info = term_info
    @state = state
    @state.register_state_viewer(self)
  end

  def update
    print_state
  end

  private
  
  def print_state
    @term_info.control("clear")
    @state.hosts_watched { |a,b| a.name <=> b.name }.each do |host|
      watcher_states = @state.states(host)
      ping_watcher_state_array = watcher_states.reject { |w,s| w.kind != "ping" }.values
      throw "Error: No ping watchers for #{host}" if ping_watcher_state_array.length == 0
      throw "Error: Multiple ping watchers for #{host}" if ping_watcher_state_array.length > 1
      puts "#{host.name}: #{ping_watcher_state_array[0]}"
    end
  end
end

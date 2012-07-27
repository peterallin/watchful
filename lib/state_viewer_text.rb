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

class StateViewerText
  def initialize(state, term_info = TermInfo)
    @term_info = term_info
    @state = state
    @state.register_state_viewer(self)
  end

  def update
    return if @state.any_unknown?
    print_state
  end

  private
  
  def print_state
    @term_info.control("clear")
    host_text_states = []
    @state.hosts_watched.sort { |a,b| a.name <=> b.name }.each do |host|
      host_text_state = "#{host.name}:\n"
      states = @state.states(host)
      states.keys.sort { |a,b| a.kind <=> b.kind }.each do |watcher|
        host_text_state << "  #{watcher.kind}: #{states[watcher].to_s.capitalize}\n"
      end
      host_text_states.push host_text_state
    end
    puts host_text_states.join "\n"
  end
end

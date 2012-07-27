Gem::Specification.new do |s|
  s.name = "watchful"
  s.version = "0.0.1dev"
  s.platform = Gem::Platform::RUBY
  s.authors = [ "Peter Allin" ]
  s.email = [ "peter@peca.dk" ]
  s.summary = "Tools for monitoring hosts on the network"
  s.description = "Supplies a number of ways for monitoring hosts on the network and the services provided by these hosts"
  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.6"
  s.files = `git ls-files`.split "\n"
  s.require_path = "lib"
  s.homepage = "https://github.com/peterallin/watchful"
  s.add_dependency("ruby-terminfo", ">= 0.1.1")
  s.executables << "wfmultiping"
end

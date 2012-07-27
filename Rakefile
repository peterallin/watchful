require 'rake'
require 'rubygems/package_task'

gemspec = eval(File.read("watchful.gemspec"))

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

desc "Build gem locally"
task :build => :gemspec do
  system "gem build #{gemspec.name}.gemspec"
  FileUtils.mkdir "pkg" unless File.exists? "pkg"
  FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", "pkg"
end

desc "Clean automatically generated files"
task :clean do
  FileUtils.rm_rf "pkg"
end

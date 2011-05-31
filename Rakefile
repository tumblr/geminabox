require "rubygems"
require "rake/gempackagetask"
require "rake/rdoctask"

task :default => :package

%w[geminabox geminabox-client geminabox-server].each do |name|
  spec = eval(File.read("#{name}.gemspec"))
  Rake::GemPackageTask.new(spec) do |pkg|
  end
end

Rake::RDocTask.new do |rd|
  rd.main = "README.markdown"
  rd.rdoc_files.include("README.markdown", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package]

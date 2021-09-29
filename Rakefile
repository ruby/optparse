require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test/lib"
  t.ruby_opts << "-rhelper"
  t.test_files = FileList["test/**/test_*.rb"]
end

task :sync_tool, [:from] do |t, from: "../ruby"|
  cp "#{from}/tool/lib/core_assertions.rb", "./test/lib"
  cp "#{from}/tool/lib/envutil.rb", "./test/lib"
  cp "#{from}/tool/lib/find_executable.rb", "./test/lib"
end

task :default => :test

task :rdoc do
  sh("rdoc", "--op", "rdoc")
end

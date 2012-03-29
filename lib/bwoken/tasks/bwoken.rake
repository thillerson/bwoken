require 'bwoken'

desc 'Remove result and trace files'
task :clean do
  print "Removing instrumentscli*.trace & #{Bwoken.path}/results/* ... "
  system "rm -rf instrumentscli*.trace #{Bwoken.path}/results/*"
  puts 'done.'
end

# task :clean_db do
  # puts "Cleaning the application's sqlite cache database"
  # system 'rm -rf ls -1d ~/Library/Application\ Support/iPhone\ Simulator/**/Applications/**/Library/Caches/TravisCI*.sqlite'
# end

desc 'Compile the workspace'
task :build do
  Bwoken::Build.new.compile
end

task :coffeescript do
  Bwoken::Coffeescript.clean
  Bwoken::Coffeescript.compile_all
end

device_families = %w(iphone ipad)

device_families.each do |device_family|

  namespace device_family do
    task :test => :coffeescript do
      Bwoken::Script.run_all device_family
    end
  end

  desc "Run tests for #{device_family}"
  task device_family => "#{device_family}:test"

end

desc 'Run all tests without compiling first'
task :test do
  if ENV['FAMILY']
    Rake::Task[ENV['FAMILY']].invoke
  else
    device_families.each do |device_family|
      Rake::Task[device_family].invoke
    end
  end
end

task :default => [:build, :test]

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Bump gem version patch number"
task :bump do
  path = File.expand_path('../lib/activefacts/compositions/version.rb', __FILE__)
  lines = File.open(path) do |fp| fp.readlines; end
  File.open(path, "w") do |fp|
    fp.write(
      lines.map do |line|
	line.gsub(/(VERSION *= *"[0-9.]*\.)([0-9]+)"\n/) do
	  version = "#{$1}#{$2.to_i+1}"
	  puts "Version bumped to #{version}\""
	  version+"\"\n"
	end
      end*''
    )
  end
end

desc "Display differences between expected and actual from the last test run"
task :actual do
  system <<-END
    for actual in `find spec -type d -name actual`
    do
      base=`dirname "$actual"`
      files="`ls $base/actual/* 2>/dev/null`"
      if [ x"$files" != x"" ]
      then
	echo "=================================== $base ==================================="
	diff -rub $base/expected/ $base/actual |grep -v '^Only in .*expected'
      fi
    done
  END
end

desc "Accept the last actual test output, making it expected for the next test run"
task :accept do
  system <<-END
    for actual_dir in `find spec -type d -name actual`
    do
      base=`dirname "$actual_dir"`
      expected=`cd "$base/expected"; git ls-files`
      actual=`cd "$base/actual"; ls $expected 2>/dev/null`
      if [ x"$actual" != x"" ]
      then
	echo "Accepting $actual"
	(cd "$base/actual"; mv $actual ../expected)
      fi
    done
  END
end

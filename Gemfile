source 'https://rubygems.org'

gemspec

this_file = File.absolute_path(__FILE__)
if this_file =~ %r{\A#{ENV['HOME']}}i and !ENV['USE_INSTALLED']
  dir = File.dirname(File.dirname(this_file))
  $stderr.puts "Using work area gems in #{dir} from activefacts-compositions"
  gem 'activefacts-api', path: dir+'/api'
  gem 'activefacts-metamodel', path: dir+'/metamodel'
  gem 'activefacts-cql', path: dir+'/cql'
end

group :development do
  gem 'byebug'
end

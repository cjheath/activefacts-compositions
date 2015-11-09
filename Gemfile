source 'https://rubygems.org'

gemspec

if ENV['PWD'] =~ %r{\A#{ENV['HOME']}/work}
  $stderr.puts "Using work area gems for #{File.basename(File.dirname(__FILE__))} from activefacts-compositions"
  gem 'activefacts-api', path: '/Users/cjh/work/activefacts/api'
  gem 'activefacts-metamodel', path: '/Users/cjh/work/activefacts/metamodel'
  gem 'activefacts-cql', path: '/Users/cjh/work/activefacts/cql'
  # gem 'activefacts-metamodel', git: 'git://github.com/cjheath/activefacts-metamodel.git'
end

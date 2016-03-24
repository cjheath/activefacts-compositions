ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'activefacts/compositions'

RSpec.configure do |config|
  rd, wr = IO.pipe
  if fork
    $stdout.reopen wr
    rd.close
  else
    $stdin.reopen rd
    wr.close
    Process.exec "tee spec/log"
  end
end

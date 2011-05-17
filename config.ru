$: <<  File.dirname(__FILE__)

require 'douban'

configure :development do
  class Sinatra::Reloader < ::Rack::Reloader
    def safe_load(file, mtime, stderr)

      if File.expand_path(file) == File.expand_path(::Sinatra::Application.app_file)
        ::Sinatra::Application.reset!
        stderr.puts "#{self.class}: reseting routes"
      end
      super
    end
  end
  
  use Sinatra::Reloader
end

Dir.mkdir 'library' if not File.exist? 'library'
Dir.mkdir 'library/tagged' if not File.exist? 'library/tagged'

run Sinatra::Application
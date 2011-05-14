require 'sinatra'
require 'open-uri'
require 'uri'
require 'pp'
require 'json'

set :app_file, __FILE__

get '/',  :host_name => /douban\.com/ do
  uri = request.env["REQUEST_URI"]
  ret =  open(URI.escape(uri) , header(request.env))

  if uri =~ /\/([a-zA-Z0-9]*.mp3)$/
    File.link ret.path, "library/#{$1}"
  end

  if uri =~/\/([a-zA-Z0-9]*.jpg)$/
    File.link ret.path, "library/#{$1}"
  end

  status ret.status[0]
  headers ret.meta
  body ret

end

get '/' do
  uri = request.env["REQUEST_URI"]
  ret =  open(URI.escape(uri) , header(request.env))

  dump_mp3_meta ret if  ret.meta["content-type"] =~ /json/

  status ret.status[0]
  headers ret.meta
  body ret
end

def dump_mp3_meta meta
  begin
    songs = JSON.parse meta.read
    songs["song"].each do |s|
      File.open("library/#{s['sid']}.json", 'w') { |f| f.write(JSON.dump s) }
    end

  rescue JSON::ParserError => err
  end
  meta.rewind
  
end

def header req
  new_head = {}
  req.select { |k,v| 
    if not k =~ /PROXY_/ and k =~ /HTTP_(.*)/
      new_head[$1] = v
    end
  }
  new_head
end

require 'sinatra'
require 'open-uri'
require 'uri'
require 'pp'
require 'json'
require 'id3lib'

set :app_file, __FILE__

get '/*' do
  halt 404 unless request.env['REQUEST_URI'] =~ /douban\.(fm|com)/
  uri, ret = getURI request

  process( uri, ret ) if ret.status[0] == '200'

  status ret.status[0]
  headers ret.meta
  body ret
end

def process(uri, ret)
  processCover($1,ret) if uri =~/\/([a-zA-Z0-9]*.jpg)$/ 
  processMp3($1,ret) if uri =~ /\/([a-zA-Z0-9]*.mp3)$/
  processJson(ret) if ret.meta['content-type'] =~ /json/
end

def processJson(meta)
  begin
    songs = JSON.parse meta.read
    songs['song'].each do |s|
      File.open("library/.meta/#{s['sid']}.json", 'w') { |f| f.write(JSON.dump s) }
    end

  rescue JSON::ParserError => err
  end
  meta.rewind
end

def processCover(filename, ret) 
  file = "library/.meta/#{filename}"
  dumpResource(file, ret)
end

def processMp3(filename, ret)
  file = "library/#{filename}"
  dumpResource(file, ret)
  fillUpTags(file)
end

def dumpResource(file, ret) 
  File.link ret.path, file if Tempfile === ret
  File.open(file, 'w') { |f| f.write ret.read; ret.rewind } if StringIO === ret
end

def conv str
  str.encode("UTF-16BE", "UTF-8")
end

def fillUpTags(file)
  file =~ /([0-9]*)\.mp3/
  if File.exist? "library/.meta/#{$1}.json"
    j = JSON.parse File.read("library/.meta/#{$1}.json")

    pic =  "library/.meta/#{File.basename(j['picture'])}"
    if not File.exist? pic
      processCover(File.basename(j['picture']), open(j['picture'].sub 'mpic', 'lpic'))
    end 

    begin
      tag = ID3Lib::Tag.new file, ID3Lib::V2
      tag.strip!
      tag << {:id => :TIT2, :text => conv(j['title']), :textenc => 1}
      tag << {:id => :TALB, :text => conv(j['albumtitle']), :textenc => 1}
      tag << {:id => :TPUB, :text => conv(j['company']), :textenc => 1}
      tag << {:id => :TPE1, :text => conv(j['artist']), :textenc => 1}
      cover = {:id => :APIC, :mimetype => 'image/jpeg', :picturetype => 3, :data => File.read(pic)}
      tag << cover
      tag.update!

      File.rename file, "library/#{j['title'].gsub(/\s/, '_')}.mp3"
    rescue Iconv::IllegalSequence => conv
    end  
  end
end

def getURI request
  uri = URI.escape(URI.unescape(request.env["REQUEST_URI"]))
  begin
    ret =  open(uri , header(request.env).merge({:redirect => false}))
  rescue OpenURI::HTTPRedirect => redirect
    ret = redirect.io
  rescue OpenURI::HTTPError => err
    ret = err.io
  end

  [uri, ret]
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

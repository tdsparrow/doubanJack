require 'json'
require 'id3lib'
require 'open-uri'
require 'iconv'

SOURCE='library'
TARGET='library/tagged'

songs = Dir.glob "#{SOURCE}/*.mp3"

def conv str
  Iconv.conv("gb18030", "UTF-8", str)
end

songs.each do |s|
  s =~ /([0-9]*)\.mp3/
  if File.exist? "#{SOURCE}/#{$1}.json"
    j = JSON.parse File.read("#{SOURCE}/#{$1}.json")

    pic =  "#{SOURCE}/#{File.basename(j['picture'])}"
    if not File.exist? pic
      f = open(j['picture'].sub 'mpic', 'lpic')
      case f
        when StringIO
        File.open(pic, 'w') {|p| p.write f.read }
        else
        File.rename f.path, pic
      end
    end 

    begin
      tag = ID3Lib::Tag.new s, ID3Lib::V2
      tag.strip!
      tag << {:id => :TIT2, :text => conv(j['title']), :textenc => 0 }
      tag << {:id => :TALB, :text => conv(j['albumtitle']), :textenc => 0 }
      tag << {:id => :TPUB, :text => conv(j['company']), :textenc => 0 }
      tag << {:id => :TPE1, :text => conv(j['artist']), :textenc => 0 }
      cover = { :id => :APIC, :mimetype => 'image/jpeg', :picturetype => 3, :data => File.read(pic) }
      tag << cover
      tag.update!
      p "Tagged mp3 #{s}"
      File.rename s, "#{TARGET}/#{File.basename s}"
    rescue Iconv::IllegalSequence => conv
    end  
    
  end
end

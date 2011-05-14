require 'json'
require 'id3lib'
require 'open-uri'
require 'iconv'

SOURCE='library'
TARGET='library/tagged'

songs = Dir.glob "#{SOURCE}/*.mp3"

songs.each do |s|
  s =~ /([0-9]*)\.mp3/
  if File.exist? "#{SOURCE}/#{$1}.json"
    j = JSON.parse File.read("#{SOURCE}/#{$1}.json")
    p j["artist"].encoding
    a16 = Iconv.iconv('utf-16le', 'utf-8', j['artist'])[0]
    p a16
    p a16[2..-1]
    a8 = Iconv.iconv('utf-8', 'utf-16le', a16).join
    p a8
    
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


    tag = ID3Lib::Tag.new s, ID3Lib::V2
    tag.strip!
    tag << {:id => :TIT2, :text => Iconv.iconv('utf-16le', 'utf-8', j["title"])[0], :textenc => 1 }
    tag << {:id => :TALB, :text => Iconv.iconv('utf-16le', 'utf-8', j["albumtitle"])[0], :textenc => 1 }
    tag << {:id => :TPUB, :text => Iconv.iconv('utf-16le', 'utf-8', j["company"])[0], :textenc => 1 }
    tag << {:id => :TPE1, :text => Iconv.iconv('utf-16le', 'utf-8', j["artist"])[0], :textenc => 1 }
    cover = { :id => :APIC, :mimetype => 'image/jpeg', :picturetype => 3, :data => File.read(pic) }
    tag << cover
    tag.update!
    p "Tagged mp3 #{s}"
    File.rename s, "#{TARGET}/#{File.basename s}"
    
end

end

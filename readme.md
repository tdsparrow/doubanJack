Introducing
===========

This is a small proxy dedicated for douban.fm (a chinese music streaming site) which will save all streamed mp3 file and fill it with the id3 tags.

mp3 files will be saved in directory "library", and covers/meta will be saved in directory "library/.meta"

How to use 
==========

Install id3lib
--------------

* Ubuntu: > sudo apt-get install libid3-toos libid3-<version>-dev
* Other linux distribution, install using its own package managment system
* Mac: > sudo port install id3lib
* Windows: good luck

Intall all dependent gems
-------------------------

`gem install bundle`

> This is will install bundle gem.

`bundle install`

> This will install all dependent gems.

Go start it
-----------

`rackup -s thin`

> This will start a mini proxy sever, then point your proxy for url including douban.com/douban.fm to this proxy. Note, douban moved one mp3 sever to a node without douban domain, you need match the whole url with 
> The default webrick sever won't accept douban playlist url because of the buggy uri parse in ruby standard library.
	
Please using the right dns server, douban return different ip to people from different places.







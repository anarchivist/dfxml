require 'nokogiri'
require 'dfxml'

# Based on http://stackoverflow.com/questions/9199859#9223767
reader = Nokogiri::XML::Reader(file)
extent = 0
count = 0
while reader.read
  if reader.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT and reader.name == 'fileobject'
    f = Dfxml::SAXReader::FileObject.parse(reader.outer_xml)
    if f.type == :file
      puts "#{f.filename}: #{f.filesize} bytes"
      extent += f.filesize.to_i
      count += 1
    end
  end
end
puts "#{count} files; #{extent} bytes total"

#
# Murdoc is *yet another* Doccu-like documentation generator.
# Murdoc reads ruby source files and produces annotated html documentation.
#
# See also: [Docco][do], [Rocco][ro]
#
# [do]: "http://jashkenas.github.com/docco/"
# [ro]: "http://rtomayko.github.com/rocco"
#


module Murdoc
  def self.generate_from_file(input, output)
    annotator = Annotator.from_file(input)
    File.open(output, "w+") do |f|
      f.puts File.read(File.dirname(__FILE__) + "/../markup/header.html")
      f.puts "<style>"
      f.puts File.read(File.dirname(__FILE__) + "/../markup/stylesheet.css")
      f.puts "</style>"
      f.puts "</head>"
      f.puts "<body>"
      annotator.paragraphs.each do |p|
        unless p.annotation.empty?
          f.puts "<div class='paragraph'>"
          f.puts p.formatted_annotation
          f.puts "</div>"
        end
        
        unless p.source.empty?
          f.puts "<figure><ol>"
          1.upto(p.source.split("\n").size) {|i| f.puts "<li>#{p.starting_line + i}</li>"}
          f.puts "</ol><code>" + p.formatted_source + "</code>"
          f.puts "</figure>"
        end
      end
      f.puts "</body>"
      f.puts File.read(File.dirname(__FILE__) + "/../markup/footer.html")
    end
  end
end

require "murdoc/annotator"
require "murdoc/paragraph"
Dir["#{File.dirname(File.expand_path(__FILE__))}/murdoc/languages/*.rb"].each {|lang| require lang }
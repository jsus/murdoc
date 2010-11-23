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
      f.puts Formatter.new("markup/template.haml").render(:paragraphs => annotator.paragraphs, :stylesheet => File.read("markup/stylesheet.css"))
    end
  end
end

require "murdoc/annotator"
require "murdoc/paragraph"
require "murdoc/formatter"

Dir["#{File.dirname(File.expand_path(__FILE__))}/murdoc/languages/*.rb"].each {|lang| require lang }
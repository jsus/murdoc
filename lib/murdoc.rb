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
  def self.generate_from_file(input, output, options = {})
    annotator = Annotator.from_file(input, nil, options)
    markup_dir = File.dirname(__FILE__)+ "/../markup"
    File.open(output, "w+") do |f|
      f.puts Formatter.new("#{markup_dir}/template.haml").render(:paragraphs => annotator.paragraphs, :stylesheet => File.read("#{markup_dir}/stylesheet.css"))
    end
  end
end

require "murdoc/annotator"
require "murdoc/paragraph"
require "murdoc/formatter"

Dir["#{File.dirname(File.expand_path(__FILE__))}/murdoc/languages/*.rb"].each {|lang| require lang }
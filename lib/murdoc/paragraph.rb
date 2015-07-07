require "rubygems"
begin
  require "rdiscount"
rescue LoadError
  require "kramdown"
end
require "cgi"
require "tempfile"

module Murdoc
  class Paragraph
    attr_accessor :source
    attr_accessor :annotation
    attr_accessor :source_type
    attr_accessor :starting_line

    def initialize(source, annotation, starting_line = 0, source_type = nil)
      self.source = source
      self.annotation = annotation
      self.starting_line = starting_line
      self.source_type = source_type
    end
  end
end

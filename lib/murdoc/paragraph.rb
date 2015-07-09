require "rubygems"
begin
  require "rdiscount"
rescue LoadError
  require "kramdown"
end
require "cgi"
require "tempfile"
require "yaml"

module Murdoc
  class Paragraph
    attr_accessor :source
    attr_accessor :annotation
    attr_accessor :source_type
    attr_accessor :starting_line
    attr_accessor :metadata

    def initialize(source, annotation, starting_line = 0, source_type = nil)
      self.source = source
      self.annotation = annotation
      self.starting_line = starting_line
      self.source_type = source_type
      extract_metadata!
    end

    def extract_metadata!
      if annotation =~ /(.*\n)?^---!([^\n]*)\n?(.*)\z/m
        self.metadata = Murdoc.try_load_yaml($2)
        self.annotation = $1.to_s + $3.to_s
      else
        self.metadata = {}
      end
    end
  end
end

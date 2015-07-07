require 'strscan'

# Annotator class does all the job: parses out comments
# and returns annotated code


# Main module
module Murdoc
  class Annotator
    attr_accessor :source

    # Attribute accessor containing the resulting paragraphs
    attr_accessor :paragraphs

    # Source language
    attr_accessor :language

    # `source` string contains annotated source code
    # `source_type` is one of supported source types (currently `[:ruby, :javascript]`)
    def initialize(source, source_type)
      self.source_type = source_type
      self.language    = Languages.get(source_type)
      self.source      = source
      self.paragraphs  = Scanner.new(language).call(source)
    end


    # You may also initialize annotator from file, it will even try to detect the
    # source type from extension.
    def self.from_file(filename, source_type = nil)
      self.new(File.read(filename),
               source_type || Languages.detect(filename))
    end

    def source_type
      @source_type
    end

    def source_type=(source_type)
      @source_type = (source_type || :base).to_sym
    end
  end
end

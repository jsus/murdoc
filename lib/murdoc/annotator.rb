require 'strscan'

# Annotator class does all the job: parses out comments
# and returns annotated code


# Main module
module Murdoc
  class Annotator
    attr_accessor :source

    # Attribute accessor containing the resulting paragraphs
    attr_accessor :paragraphs

    # Options
    # Available options:
    #   `:highlight_source` -- highlights source syntax using pygments (default: true)
    attr_accessor :options
    attr_accessor :language

    def self.default_options
      {
        :highlight_source => true
      }
    end


    # `source` string contains annotated source code
    # `source_type` is one of supported source types (currently `[:ruby, :javascript]`)
    def initialize(source, source_type, options = {})
      self.source_type = source_type
      self.language    = Languages.get(source_type)
      self.options     = self.class.default_options.merge(options)
      self.source      = source
      self.paragraphs  = Scanner.new(language).call(source)
    end


    # You may also initialize annotator from file, it will even try to detect the
    # source type from extension.
    def self.from_file(filename, source_type = nil, options = {})
      self.new(File.read(filename),
               source_type || Languages.detect(filename),
               options)
    end

    def source_type
      @source_type
    end

    def source_type=(source_type)
      @source_type = (source_type || :base).to_sym
    end
  end
end

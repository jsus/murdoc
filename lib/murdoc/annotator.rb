require 'yaml'

module Murdoc
  class Annotator
    attr_accessor :source
    attr_accessor :metadata
    # Attribute accessor containing the resulting paragraphs
    attr_accessor :paragraphs

    # Source language
    attr_accessor :language

    # `source` string contains annotated source code
    # `source_type` is one of supported source types (currently `[:ruby, :javascript]`)
    def initialize(source, source_type, do_not_count_comment_lines = false)
      self.source, self.metadata = extract_metadata(source)
      self.source_type = source_type
      self.language = Languages.get(source_type)
      self.paragraphs = if !language.annotation_only?
        Scanner.new(language).call(self.source, do_not_count_comment_lines)
      else
        [Paragraph.new('', self.source, 0, nil)]
      end
    end


    # You may also initialize annotator from file, it will even try to detect the
    # source type from extension.
    def self.from_file(filename, source_type = nil, do_not_count_comment_lines = false)
      self.new(File.read(filename),
               source_type || Languages.detect(filename),
               do_not_count_comment_lines)
    end

    def extract_metadata(source)
      if source =~ /\A---\n(.*?)\n---\n(.*)\z/m && (metadata = try_load_yaml($1))
        [$2, metadata]
      else
        [source, {}]
      end
    end

    def source_type
      @source_type
    end

    def source_type=(source_type)
      @source_type = (source_type || :base).to_sym
    end

    def try_load_yaml(yaml)
      YAML.load(yaml)
    rescue => e
      nil
    end
  end
end

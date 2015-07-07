module Murdoc
  module Languages
    # Base language module
    #
    # Any new language module should inherit from Base, redefine .extensions
    # and .comment_symbols methods, if needed, and add itself to Languages.map
    # map.
    class Base
      def self.applies_for?(filename)
        if extensions.include?(File.extname(filename).sub(/^\./, ''))
          true
        else
          false
        end
      end

      def self.annotation_only?
        false
      end

      def self.extensions
        []
      end

      def self.comment_symbols
        {
          single_line: nil,
          multiline: nil
        }
      end

      def self.name
        super.sub(/^(.*::)?([^:]+)$/, '\\2').
              gsub(/([a-z])([A-Z])/, '\\1_\\2').
              downcase.to_sym
      end
    end

    def self.map
      @map ||= {}
    end

    def self.list
      map.values
    end

    def self.get(name)
      map.fetch(name, Base)
    end

    def self.detect(filename)
      name, lang = map.detect {|name, lang| lang.applies_for?(filename) }
      name
    end
  end
end

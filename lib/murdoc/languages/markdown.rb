# Html language module
module Murdoc
  module Languages
    class Markdown < Base
      def self.comment_symbols
        {
          single_line: nil,
          multiline: nil
        }
      end

      def self.annotation_only?
        true
      end

      def self.extensions
        ['markdown', 'md']
      end
    end

    self.map[:md] = Markdown
    self.map[:markdown] = Markdown
  end
end

# Html language module
module Murdoc
  module Languages
    class Html < Base
      def self.comment_symbols
        {
          single_line: nil,
          multiline: {
            :begin => "<!--",
            :end => "-->"
          }
        }
      end

      def self.extensions
        ['html']
      end
    end

    self.map[:html] = Html
  end
end

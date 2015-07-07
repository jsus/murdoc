module Murdoc
  module Languages
    class Javascript < Base
      def self.comment_symbols
        {
          single_line: '//',
          multiline: {
            :begin => "/*",
            :end => "*/"
          }
        }
      end

      def self.extensions
        ['js']
      end
    end

    self.map[:js] = Javascript
    self.map[:javascript] = Javascript
  end
end

# Ruby language module
module Murdoc
  module Languages
    class Ruby < Base
      def self.comment_symbols
        {
          single_line: '#',
          multiline: {
            :begin => "=begin",
            :end => "=end"
          }
        }
      end

      def self.extensions
        ['rb']
      end
    end

    self.map[:ruby] = Ruby
  end
end

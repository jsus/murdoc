# Html language module
module Murdoc
  module Languages
    class Coffeescript < Base
      def self.comment_symbols
        {
          single_line: '#',
          multiline: {
            :begin => "###",
            :end => "###"
          }
        }
      end

      def self.extensions
        ['coffee']
      end
    end

    self.map[:coffee] = Coffeescript
    self.map[:coffeescript] = Coffeescript
  end
end

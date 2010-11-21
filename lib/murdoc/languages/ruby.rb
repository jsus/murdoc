# Ruby language module
module Murdoc
  module Languages
    module Ruby
      module Annotator
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          protected
          def detect_source_type_from_filename(filename)
            if File.extname(filename) == ".rb"
              :ruby
            else
              super if defined?(super)
            end
          end
        end
      end

      module CommentSymbols
        protected
        def comment_symbols
          if source_type == "ruby"
            {:single_line => "#", :multiline => {:begin => "=begin", :end => "=end"}}
          else
            super if defined?(super)
          end
        end
      end
    end
  end

  class Annotator
    include Languages::Ruby::Annotator
    include Languages::Ruby::CommentSymbols
  end

  class Paragraph
    include Languages::Ruby::CommentSymbols
  end
end
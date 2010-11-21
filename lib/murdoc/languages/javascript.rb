# Javascript language module
module Murdoc
  module Languages
    module Javascript
      module Annotator
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          protected
          def detect_source_type_from_filename(filename)
            if File.extname(filename) == ".js"
              :javascript
            else
              super if defined?(super)
            end
          end
        end
      end

      module CommentSymbols
        protected
        def comment_symbols
          if source_type == "javascript"
            {:single_line => "//", :multiline => {:begin => "/*", :end => "*/"}}
          else
            super if defined?(super)
          end
        end
      end
    end
  end

  class Annotator
    include Languages::Javascript::Annotator
    include Languages::Javascript::CommentSymbols
  end

  class Paragraph
    include Languages::Javascript::CommentSymbols
  end
end
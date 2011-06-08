# Html language module
module Murdoc
  module Languages
    module Html
      module Annotator
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          protected
          def detect_source_type_from_filename(filename)
            if File.extname(filename) == ".html"
              :html
            else
              super if defined?(super)
            end
          end
        end
      end

      module CommentSymbols
        protected
        def comment_symbols
          if source_type == "html"
            {:single_line => nil, :multiline => {:begin => "<!--", :end => "-->"}}
          else
            super if defined?(super)
          end
        end
      end
    end
  end

  class Annotator
    include Languages::Html::Annotator
    include Languages::Html::CommentSymbols
  end

  class Paragraph
    include Languages::Html::CommentSymbols
  end
end

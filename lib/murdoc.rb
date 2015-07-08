#
# Murdoc is *yet another* Doccu-like documentation generator.
# Murdoc reads ruby source files and produces annotated html documentation.
#
# See also: [Docco][do], [Rocco][ro]
#
# [do]: "http://jashkenas.github.com/docco/"
# [ro]: "http://rtomayko.github.com/rocco"
#


module Murdoc
  # `AnnotatedFile` is a struct we pass into our templates
  AnnotatedFile = Struct.new(:filename, :metadata, :source, :source_type, :paragraphs, :formatted_paragraphs)

  # `Murdoc.annotate` arguments are gathered from CLI utility
  #
  # `highlight` regulates syntax highlighting and `do_not_count_comment_lines` flag
  # toggles counting comment lines towards line numbering in the output.
  def self.annotate(filename, highlight = true, do_not_count_comment_lines = false)
    filename = File.expand_path(filename)
    annotator = Annotator.from_file(filename, nil, do_not_count_comment_lines)
    AnnotatedFile.new(filename,
        annotator.metadata,
        annotator.source,
        annotator.source_type,
        annotator.paragraphs,
        annotator.paragraphs.map {|p| FormattedParagraph.new(p, highlight) })
  end

  # Generate a single file story
  def self.generate_from_file(input, output, options = {})
    options = default_options.merge(options)
    annotator = Annotator.from_file(input, nil)
    File.open(output, "w+") do |f|
      annotated_file = annotate(input, options[:highlight], options[:do_not_count_comment_lines])
      f.puts Renderer.new(options[:template]).render(:annotated_file => annotated_file,
                                                     :stylesheet => File.read(options[:stylesheet]))
    end
  end

  # ... or use multiple files
  def self.generate_from_multiple_files(input_files, output, options = {})
    options = default_options_for_multiple_files.merge(options)
    annotated_files = input_files.map {|fn| annotate(fn, options[:highlight], options[:do_not_count_comment_lines]) }
    File.open(output, "w+") do |f|
      f.puts Renderer.new(options[:template]).render(:annotated_files => annotated_files,
                                                     :stylesheet => File.read(options[:stylesheet]))
    end
  end


  # Rest is self-explanatory
  def self.default_options
    @options ||= {
      template:   "#{markup_dir}/template.haml",
      stylesheet: "#{markup_dir}/stylesheet.css",
      highlight: true
    }
  end

  def self.default_options_for_multiple_files
    @options ||= {
      template:   "#{markup_dir}/template_multifile.haml",
      stylesheet: "#{markup_dir}/stylesheet.css",
      highlight: true
    }
  end

  def self.markup_dir
    File.expand_path("../..", __FILE__)+ "/markup"
  end
end

require "murdoc/annotator"
require "murdoc/scanner"
require "murdoc/paragraph"
require "murdoc/formatted_paragraph"
require "murdoc/renderer"
require "murdoc/languages/base"
require "murdoc/languages/html"
require "murdoc/languages/coffeescript"
require "murdoc/languages/javascript"
require "murdoc/languages/ruby"
require "murdoc/languages/markdown"

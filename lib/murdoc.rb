#
# Murdoc is *yet another* Doccu-like documentation generator.
# Murdoc reads ruby source files and produces annotated html documentation.
#
# See also: [Docco][do], [Rocco][ro]
#
# [do]: "http://jashkenas.github.com/docco/"
# [ro]: "http://rtomayko.github.com/rocco"
#

require 'fileutils'
require 'pathname'

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

  # Generate a documentation tree
  def self.generate_tree(input_dir, output_dir, has_parent = false, base_dir = nil, options = {})
    options = default_options_for_tree.merge(options)
    input_dir = Pathname(input_dir).expand_path
    output_dir = Pathname(output_dir).expand_path
    base_dir ||= input_dir

    FileUtils.mkdir_p(output_dir)

    entries = input_dir.children

    directories = entries.select(&:directory?).
                          reject {|dir| dir == output_dir }.
                          reject {|dir| dir.basename.to_s.start_with?('.')}
    directories.each do |dir|
      next if dir == output_dir
      generate_tree(dir,
                    output_dir + dir.relative_path_from(input_dir),
                    true,
                    base_dir,
                    options)
    end

    files = entries.select(&:file?).select {|file| Languages.detect(file.to_s) }
    files.each do |file|
      relpath = file.relative_path_from(input_dir)
      generate_from_file(file, "#{output_dir}/#{relpath}.html", {
        highlight: options[:highlight],
        template: options[:template],
        stylesheet: options[:stylesheet],
        do_not_count_comment_lines: options[:do_not_count_comment_lines]
      })
    end

    unless files.empty? && directories.empty?
      generate_index("#{output_dir}/index.html", {
       current_directory: input_dir,
       files: files,
       directories: directories,
       has_parent: has_parent,
       base_dir: base_dir,
       template: options[:index_template],
       stylesheet: options[:index_stylesheet]
      })
    end
  end

  def self.generate_index(fn, options)
    options = default_options_for_index.merge(options)
    File.open(fn, 'w+') do |f|
      f.puts Renderer.new(options[:template]).render({
        stylesheet: File.read(options[:stylesheet]),
        base_dir: options[:base_dir],
        has_parent: options[:has_parent],
        current_directory: options[:current_directory],
        files: options[:files],
        directories: options[:directories]
      })
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
    @options_multi ||= {
      template:   "#{markup_dir}/template_multifile.haml",
      stylesheet: "#{markup_dir}/stylesheet.css",
      highlight: true
    }
  end

  def self.default_options_for_tree
    @options_tree ||= {
      index_template: default_options_for_index[:template],
      index_stylesheet: default_options_for_index[:stylesheet],
      template: default_options[:template],
      stylesheet: default_options[:stylesheet],
      highlight: default_options[:highlight],
      do_not_count_comment_lines: false
    }
  end

  def self.default_options_for_index
    @options_index ||= {
      template: "#{markup_dir}/template_index.haml",
      stylesheet: "#{markup_dir}/stylesheet.css"
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

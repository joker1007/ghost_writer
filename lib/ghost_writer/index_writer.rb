require 'active_support/core_ext/string'

class GhostWriter::IndexWriter
  autoload "Markdown", "ghost_writer/index_writer/markdown"
  autoload "Rst", "ghost_writer/index_writer/rst"

  def initialize(document_index, options = {})
    @document_index  = document_index
    @format          = options.delete(:format) || :markdown
  end

  def write_file
    format_class = lookup_format_class
    format = format_class.new(@document_index)
    format.write_file
  end

  private

  def lookup_format_class
    case @format
    when Class
      @format
    when String, Symbol
      "GhostWriter::IndexWriter::#{@format.to_s.classify}".constantize
    end
  end
end

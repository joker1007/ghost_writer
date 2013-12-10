require 'active_support/core_ext/string'

class GhostWriter::Writer
  autoload "Markdown", "ghost_writer/writer/markdown"
  autoload "Rst", "ghost_writer/writer/rst"

  def initialize(document, options = {})
    @document  = document
    @format    = options.delete(:format) || :markdown
    @options   = options
  end

  def write_file
    format_class = lookup_format_class
    format = format_class.new(@document, @options)
    format.write_file
  end

  private

  def lookup_format_class
    case @format
    when Class
      @format
    when String, Symbol
      "GhostWriter::Writer::#{@format.to_s.classify}".constantize
    end
  end
end

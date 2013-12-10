require 'ghost_writer/index_writer'

class GhostWriter::DocumentIndex
  attr_reader :basename, :document_group

  def initialize(basename, document_group, format)
    @basename = basename
    @document_group = document_group
  end

  def write_file(options = {})
    writer = GhostWriter::IndexWriter.new(self, options)
    writer.write_file
  end

  def base_url
    if GhostWriter.github_base_url
      base_url = GhostWriter.github_base_url + "/"
    else
      base_url = ""
    end
  end
end

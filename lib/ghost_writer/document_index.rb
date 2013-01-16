class GhostWriter::DocumentIndex
  attr_reader :output, :documents

  def initialize(output, documents)
    extend(GhostWriter::Format::Markdown)
    @output = output
    @documents = documents
  end

  def write_file
    if GhostWriter.github_base_url
      base_url = GhostWriter.github_base_url + "/"
    else
      base_url = ""
    end

    document_list = documents.map do |document|
      list(
        link(document.description, base_url + "#{document.relative_path}")
      )
    end

    index_file = File.open(output, "w")
    index_file.write paragraph(<<EOP)
#{headword("API Examples")}
#{document_list.join("\n")}
EOP
    index_file.close
  end
end

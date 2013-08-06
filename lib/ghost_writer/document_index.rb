class GhostWriter::DocumentIndex
  attr_reader :output, :documents

  def initialize(output, documents, format)
    format_module = "GhostWriter::Format::#{format.to_s.classify}"
    extend(format_module.constantize)

    @output = output
    @documents = documents
  end

  def write_file
    if GhostWriter.github_base_url
      base_url = GhostWriter.github_base_url + "/"
    else
      base_url = ""
    end

    document_list = documents.flat_map do |output, docs|
      docs.map do |d|
        list(
          link(d.description, base_url + "#{d.relative_path}")
        )
      end
    end

    index_file = File.open(output, "w")
    index_file.write paragraph(<<EOP)
#{headword("API Examples")}
#{document_list.join("\n")}
EOP
    index_file.close
  end
end

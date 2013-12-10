class GhostWriter::IndexWriter
  class Base
    def initialize(document_index)
      @document_index = document_index
    end

    def write_file
      unless File.exist?(File.dirname(@document_index.basename))
        FileUtils.mkdir_p(File.dirname(@document_index.basename))
      end

      File.open("#{@document_index.basename}.#{extname}", "w") do |f|
        f.write template.result(@document_index.instance_eval { binding })
      end
    end

    private

    def extname
      raise NotImplementedError
    end

    def template
      raise NotImplementedError
    end
  end
end

require 'erb'

class GhostWriter::Writer
  class Base
    def initialize(document, options = {})
      @document  = document
      @overwrite = options[:overwrite] || false
    end

    def write_file
      unless File.exist?(File.dirname(@document.basename))
        FileUtils.mkdir_p(File.dirname(@document.basename))
      end

      mode = @overwrite ? "w" : "a"
      File.open("#{@document.basename}.#{extname}", mode) do |f|
        f.write template.result(@document.instance_eval { binding })
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

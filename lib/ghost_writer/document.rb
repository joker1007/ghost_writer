require 'ghost_writer/writer'

class GhostWriter::Document
  attr_reader :basename, :relative_path, :title, :description, :location, :request_method, :path_info, :response_format, :param_example, :status_code
  attr_accessor :header

  def initialize(basename, attrs)
    @basename         = basename
    @relative_path    = Pathname.new(basename).relative_path_from(GhostWriter.output_path)
    @title            = attrs[:title]
    @description      = attrs[:description]
    @location         = attrs[:location]
    @request_method   = attrs[:request_method]
    @path_info        = attrs[:path_info]

    param_example     = attrs[:param_example].stringify_keys
    @response_format  = param_example.delete("format").to_s
    @param_example    = param_example
    @status_code      = attrs[:status_code]
    @response_body    = attrs[:response_body]
  end

  def write_file(options = {})
    writer = GhostWriter::Writer.new(self, options)
    writer.write_file
  end

  def serialized_params
    MultiJson.dump(param_example)
  end

  def response_body
    arrange_json(@response_body)
  end

  def response_format(json_convert_to_javascript = false)
    if json_convert_to_javascript && @response_format == "json"
      "javascript"
    else
      @response_format
    end
  end

  private

  def arrange_json(body)
    data = ActiveSupport::JSON.decode(body)
    if data.is_a?(Array) || data.is_a?(Hash)
      JSON.pretty_generate(data)
    else
      data
    end
  rescue MultiJson::DecodeError
    body
  end
end

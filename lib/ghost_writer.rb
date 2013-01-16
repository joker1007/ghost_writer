require "ghost_writer/version"
require "ghost_writer/document"
require "active_support/concern"

module GhostWriter
  extend ActiveSupport::Concern

  mattr_accessor :output_dir

  def generate_api_doc
    @@output_path = @@output_dir ? Rails.root + "doc" + @@output_dir : Rails.root + "doc" + "api_examples"
    unless File.exist?(doc_dir)
      FileUtils.mkdir_p(doc_dir)
    end

    document = GhostWriter::Document.new(File.join(doc_dir, "#{doc_name}.markdown"), {
      title: "#{described_class} #{doc_name.titleize}",
      description: example.full_description.dup,
      location: example.location.dup,
      url_example: "#{request.env["REQUEST_METHOD"]} #{request.env["PATH_INFO"]}",
      param_example: controller.params.reject {|key, val| key == "controller" || key == "action"},
      status_example: response.status.inspect,
      response_example: response.body,
    })
    document.write_file
  end

  private
  def doc_dir
    @@output_path + described_class.to_s.underscore
  end

  def doc_name
    if example.metadata[:generate_api_doc].is_a?(String) || example.metadata[:generate_api_doc].is_a?(Symbol)
      example.metadata[:generate_api_doc].to_s
    else
      controller.action_name
    end
  end

  included do
    after do
      if example.metadata[:type] == :controller && example.metadata[:generate_api_doc]
        generate_api_doc if ENV["GENERATE_API_DOC"]
      end
    end
  end
end

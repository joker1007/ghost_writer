module GhostWriter
  module Format
    module Rack
      def write_index_file
        rack = <<RUBY
require 'rack'

class DummyApp
  def call(env)
    request = Rack::Request.new(env)
    case [request.request_method, request.path_info, request.params]

RUBY
        documents.each do |output, docs|
          docs.each do |d|
            rack += <<RUBY
    when [#{d.request_method.inspect}, #{d.path_info.inspect}, #{d.param_example.reject {|k, v| k == "format"}.inspect}]
      [200, {"Content-Type" => #{d.content_type.inspect}}, [(<<BODY)]]
#{d.response_example}
BODY
RUBY
          end
        end
        rack += <<RUBY
    else
      [404, {"Content-Type" => "text/html"}, ['No match rule']]
    end
  end
end
RUBY
        File.open("#{output}.#{extname}", "w") do |f|
          f.write rack
        end
      end

      def write_file(overwrite = false)
      end

      def content_type
        if param_example["format"] == "json"
          "application/json; charset=UTF-8"
        else
          "text/html; charset=UTF-8"
        end
      end

      private

      def extname
        "rb"
      end
    end
  end
end

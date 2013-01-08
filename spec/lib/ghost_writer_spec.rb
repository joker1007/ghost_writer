require "spec_helper"

class AnonymousController
end

describe GhostWriter do

  let(:group) do
    RSpec::Core::ExampleGroup.describe do
      include RSpec::Rails::ControllerExampleGroup
      include GhostWriter

      def described_class
        AnonymousController
      end

      controller do
        def index
          collection = [
            {
              id: 1,
              name: "name",
            },
            {
              id: 2,
              name: "name",
            },
          ]
          render json: collection.as_json
        end
      end

      describe "GET index" do
        it "should be success", generate_api_doc: true do
          begin
            get :index
            response.should be_success
          rescue Exception => e
            p e
          end
        end
      end
    end
  end

  context "Not given output_dir" do
    before do
      clear_output("api_examples")
    end

    after do
      clear_output("api_examples")
    end

    it "generate api doc file" do
      ENV["GENERATE_API_DOC"] = "1"
      group.run(NullObject.new)
      File.exist?(Rails.root + "doc" + "api_examples" + "anonymous_controller" + "index.markdown").should be_true
    end
  end

  context "Given output_dir" do
    let(:output_dir) { "api_docs" }

    before do
      GhostWriter.output_dir = output_dir
      clear_output(output_dir)
    end

    after do
      GhostWriter.output_dir = nil
      clear_output(output_dir)
    end

    it "generate api doc file" do
      ENV["GENERATE_API_DOC"] = "1"
      group.run(NullObject.new)
      File.exist?(Rails.root + "doc" + output_dir + "anonymous_controller" + "index.markdown").should be_true
    end
  end

  def clear_output(dirname)
    if File.exist?(Rails.root + "doc" + dirname)
      FileUtils.rm_r(Rails.root + "doc" + dirname)
    end
  end
end

ENV["RAILS_ENV"] = "test"

$:.unshift File.dirname(__FILE__)

require "rails_app/config/environment"

I18n.load_path << File.expand_path("../support/locale/en.yml", __FILE__)

require "rspec/rails"

class NullObject
  private
  def method_missing(method, *args, &block)
    # ignore
  end
end

# GhostWriter
[![Build Status](https://travis-ci.org/joker1007/ghost_writer.png)](https://travis-ci.org/joker1007/ghost_writer)
[![Gem Version](https://badge.fury.io/rb/ghost_writer.png)](http://badge.fury.io/rb/ghost_writer)

Generate API examples from params and response of controller specs

## Installation

Add this line to your application's Gemfile:

    gem 'ghost_writer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ghost_writer

## Usage

Write controller spec:
```ruby
# spec_helper
RSpec.configure do |config|
  # The difference with previous version. already no need including Module and Defining after hook
  GhostWriter.output_dir = "api_docs" # Optional (default is "api_examples")
  GhostWriter.github_base_url = "https://github.com/joker1007/ghost_writer/tree/master/output_examples" # Optional
end

# posts_controller_spec
require 'spec_helper'

describe PostsController do
  describe "GET index" do
    it "should be success", generate_api_doc: true do # Add metadata :generate_api_doc
      get :index
      response.should be_success
    end

    it "should be success", generate_api_doc: "index_error" do # if metadata value is string, use it as filename
      get :index
      response.status.should eq 404
    end
  end
end
```

And set environment variable GENERATE_API_DOC at runtime
```
bundle exec ghost_writer spec/controllers
-> generate docs at [Rails.root]/doc/api_examples
```

If you don't set environment variable, this gem doesn't generate docs.

*Caution: Using ghost_writer command and Defining after fook manually at the same time, after hook is executed twice, and so document_index is cleared.*

## Output Example
Please look at [output_examples](https://github.com/joker1007/ghost_writer/tree/master/output_examples)

## Config
If output_dir is set, generate docs at `[Rails.root]/doc/[output_dir]`

If github\_base\_url is set, link index is based on the url, like output\_examples

## TODO
- support more output formats (now markdown only)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

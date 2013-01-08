class PostsController < ApplicationController
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

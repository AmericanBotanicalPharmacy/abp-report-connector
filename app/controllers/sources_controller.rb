class SourcesController < ApplicationController
  before_action :authenticate_user!

  def index
    @sources = current_user.sources
  end
end
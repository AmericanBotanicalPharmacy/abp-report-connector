class SourcesController < ApplicationController
  before_action :authenticate_user!

  def index
    @sources = current_user.sources
  end

  def new
    @source = DatabaseSource.new
  end

  def create
    @source = DatabaseSource.new(source_params)
    if @source.save
      flash[:notice] = 'Successfully create database'
      redirect_to sources_path
    else
      render :create
    end
  end

  private

  def source_params
    params.require(:database_source).permit!
  end
end
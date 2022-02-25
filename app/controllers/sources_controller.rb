require 'securerandom'

class SourcesController < ApplicationController
  before_action :authenticate_user!

  def index
    @sources = current_user.sources
  end

  def new
    @source = DatabaseSource.new
  end

  def create
    @source = current_user.sources.new(source_params.merge(uuid: SecureRandom.uuid))
    if @source.save
      flash[:notice] = 'Successfully create database'
      redirect_to sources_path
    else
      flash[:error] = @source.errors.full_messages.join(',')
      render :new
    end
  end

  def edit
    @source = current_user.sources.find(params[:id])
  end

  def update
    @source = current_user.sources.find(params[:id])
    if @source.update(source_params)
      flash[:notice] = 'Successfully update database'
      redirect_to sources_path
    else
      flash[:error] = @source.errors.full_messages.join(',')
      render :edit
    end
  end

  private

  def source_params
    params.require(:database_source).permit!
  end
end
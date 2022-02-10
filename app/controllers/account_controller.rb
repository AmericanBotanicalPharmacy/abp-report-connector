class AccountController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def privacy_policy
  end
end

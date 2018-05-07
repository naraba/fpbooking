class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def hello
    render html: "hello, world"
  end

  def after_sign_in_path_for(_resource)
    slots_path
  end
end

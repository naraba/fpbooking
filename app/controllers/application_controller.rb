class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def hello
    render html: "hello, world"
  end

  def after_sign_in_path_for(resource)
    slots_path
  end
end

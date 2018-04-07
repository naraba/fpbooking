# frozen_string_literal: true

class Fps::SessionsController < Devise::SessionsController
  include CrossVisit
  before_action :configure_sign_in_params, only: [:create]
  before_action :check_user_signed, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected
    def configure_sign_in_params
      devise_parameter_sanitizer.permit(
        :sign_in,
        keys: [ :email, :password ])
    end
end

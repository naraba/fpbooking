class StaticPagesController < ApplicationController
  def home
    if fp_signed_in? || user_signed_in?
      redirect_to slots_path
    end
  end

  def about
  end
end

module CrossVisit
  extend ActiveSupport::Concern

  def check_user_signed
    if user_signed_in?
      flash[:danger] = "ユーザとしてログイン中です"
      redirect_to root_url
    end
  end

  def check_fp_signed
    if fp_signed_in?
      flash[:danger] = "フィナンシャルプランナーとしてログイン中です"
      redirect_to root_url
    end
  end
end

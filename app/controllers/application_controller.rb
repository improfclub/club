class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :capture_referal, :user_id
  private
  def capture_referal
    session[:p] = params[:p] if params[:p]
  end
  def user_id
    session[:id] = params[:id] if params[:id]
  end
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :last_name, :phone, :skype, :birthday, :sex, :country, :city, :about, :role, :email, :password, :password_confirmation, :remember_me, :referral_code, :avatar, :avatar_cache) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :last_name, :phone, :skype, :birthday, :sex, :county, :city, :about, :role, :email, :password, :password_confirmation, :current_password, :referral_code, :avatar, :avatar_cache, :remove_avatar) }
  end
  def ensure_signup_complete
    # Ensure we don't go into an infinite loop
    return if action_name == 'finish_signup'

    # Redirect to the 'finish_signup' page if the user
    # email hasn't been verified yet
    if current_user && !current_user.email_verified?
      redirect_to finish_signup_path(current_user)
    end
  end
  def make_payment_services
    @services = []
    @services.push(
     {
          'action' => 'https://www.nixmoney.com/merchant.jsp',
          'name' => "nixmoney",
          'fields' => {
            'PAYEE_ACCOUNT' => 'U52137923986425',
            'PAYEE_NAME' => 'Test',
            'PAYMENT_AMOUNT' => 2,
            'STATUS_URL' => "http://improf.club/finance_api/responce-status/nixmoney",
            'PAYMENT_URL' => 'http://improf.club/finance_api/success/nixmoney',
            'NOPAYMENT_URL' => 'http://improf.club/finance_api/error/nixmoney',
            'BAGGAGE_FIELDS' => 'user_id',
            'user_id' => current_user.id,
          }
        }
       )
    @services.push(
     {
          'action' => "https://perfectmoney.is/api/step1.asp",
          'name' => "perfectmoney",
          'fields' => {
            'PAYEE_ACCOUNT' => "U8200384",
            'PAYEE_NAME' => "improf.club",
            'PAYMENT_AMOUNT' => 2,
            'PAYMENT_UNITS' => 'USD',
            'STATUS_URL' => "http://improf.club/finance_api/responce-status/perfect_money",
            'PAYMENT_URL' => 'http://improf.club/finance_api/success/perfect_money',
            "PAYMENT_URL_METHOD" => "LINK",
            'NOPAYMENT_URL' => 'http://improf.club/finance_api/error/perfect_money',
            "NOPAYMENT_URL_METHOD" => "LINK",
            'SUGGESTED_MEMO' => "",
            'BAGGAGE_FIELDS' => 'user_id',
            'user_id' => current_user.id,
            "PAYMENT_METHOD" => "Pay Now!"
        }
        }
       )
  end
end

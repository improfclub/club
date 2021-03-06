class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :capture_referal, :user_id
  before_filter :ensure_signup_complete
  helper_method :user_has_rights
  private
  def capture_referal
    session[:p] = params[:p] if params[:p]
  end
  def user_id
    session[:id] = params[:id] if params[:id]
  end

  def user_has_rights
    return true if current_user.role.name != 'user' || Rails.env == 'development'
  end
  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :last_name, :phone, :skype, :birthday, :sex, :country, :city, :about, :role, :email, :password, :password_confirmation, :remember_me, :referral_code, :avatar, :avatar_cache) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :last_name, :phone, :skype, :birthday, :sex, :county, :city, :about, :role, :email, :password, :password_confirmation, :current_password, :referral_code, :avatar, :avatar_cache, :remove_avatar) }
  end
  def ensure_signup_complete
    if user_signed_in?
      @need_finish_rigistration = !(
        current_user.vk &&
        current_user.phone)
    end
  end
  private
  def random_key
    (0...8).map { (65 + rand(26)).chr }.join
  end
  def make_payment_services
    @services = []
    @services.push(
     {
          'action' => 'https://www.nixmoney.com/merchant.jsp',
          'name' => "nixmoney",
          'fields' => {
            'PAYMENT_ID' => random_key,
            'PAYEE_ACCOUNT' => 'U52137923986425',
            'PAYEE_NAME' => 'Test',
            'PAYMENT_AMOUNT' => 2,
            'PAYMENT_UNITS' => 'USD',
            'STATUS_URL' => "http://improf.club/finance_api/responce_status/nixmoney",
            'PAYMENT_URL' => 'http://improf.club/finance_api/success/nixmoney',
            "PAYMENT_URL_METHOD" => "GET",
            'NOPAYMENT_URL' => 'http://improf.club/finance_api/error/nixmoney',
            "NOPAYMENT_URL_METHOD" => "GET",
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
            'PAYMENT_ID' => random_key,
            'PAYEE_ACCOUNT' => "U8200384",
            'PAYEE_NAME' => "improf.club",
            'PAYMENT_AMOUNT' => 2,
            'PAYMENT_UNITS' => 'USD',
            'STATUS_URL' => "http://improf.club/finance_api/responce_status/perfectmoney",
            'PAYMENT_URL' => 'http://improf.club/finance_api/success/perfectmoney',
            "PAYMENT_URL_METHOD" => "GET",
            'NOPAYMENT_URL' => 'http://improf.club/finance_api/error/perfectmoney',
            "NOPAYMENT_URL_METHOD" => "GET",
            'SUGGESTED_MEMO' => "",
            'BAGGAGE_FIELDS' => 'user_id',
            'user_id' => current_user.id,
            "PAYMENT_METHOD" => "Pay Now!"
        }
        }
    )
    @services.push(
     {
          'action' => "https://wallet.advcash.com/sci/",
          'name' => "advcash",
          'fields' => {
            'ac_account_email' => "club.mlm30@gmail.com",
            'ac_sci_name' => "Professionals Club",
            'ac_amount' => 2,
            'ac_currency' => 'USD',
            'ac_status_url' => "http://improf.club/finance_api/responce_status/advcash",
            'ac_status_url_method' => 'POST',
            'ac_success_url' => 'http://improf.club/finance_api/success/advcash',
            'ac_success_url_method' => "GET",
            'ac_fail_url' => 'http://improf.club/finance_api/error/advcash',
            'ac_fail_url_method' => 'GET',
            "ac_sign" => ENV['ADV_CASH_SIGN'],
            "ac_order_id" => random_key,
            "ac_comments" => "Adcanced Cash payment.",
            "user_id" => current_user.id
          }
      }
    )
    @services.push(
     {
          'action' => "https://www.liqpay.com/api/3/checkout",
          'name' => "liqpay",
          'fields' => {
            'data' => "",
            'signature' => ""
          }
      }
    )
  end
end

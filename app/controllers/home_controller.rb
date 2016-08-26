class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_signup_complete, only: [:index]
  
  def index
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




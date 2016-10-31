require 'rails_helper'

RSpec.describe FinanceApiController, type: :controller do

  describe "#responce_status" do
    it "NIX MONEY increae number of payments in the system" do
    
      expect { 
      	post :responce_status, :id => "nixmoney", 
      	"user_id" => 2, 
      	'PAYMENT_ID' => '1',
  	  	'PAYEE_ACCOUNT' => 'U52137923986425',
  	  	'PAYMENT_AMOUNT' => '1.00',
  	  	'PAYMENT_UNITS' => 'USD',
  	  	'PAYMENT_BATCH_NUM' => '607873',
  	  	'PAYER_ACCOUNT' => 'U33537306942179',
  	  	'V2_HASH' => 'F645AEDA110F9A0DBF7DF538423F0661',
  	  	'TIMESTAMPGMT' => '1474215852'
		}.to  change { Payment.count }
      # expect(wallet.main_balance).to   eq(balance_prev + mock_params['ac_amount'].to_f)
      # expect(response).to have_http_status(200)
    end
  end

end
class FinanceApiController < ApplicationController

  before_action :prepare_input_data, except: [:payment_form]

  require 'digest'
  require "base64"
  require 'json'

  def responce_status
    unless @responce_data[:success] 
      head 422
    end
    update_user_balance
    
    puts "balance after function" + Wallet.find_by(user_id: @responce_data[:user_id]).main_balance.to_s
    head 200
  end

  def success
    flash[:notice] = "Поздравляем! Ваш баланс пополнен на #{@responce_data[:amount]}$"
	  redirect_to_home_after_payment(true)
  end

  def error
    flash[:error] = "Счет не пополнен"
  	redirect_to_home_after_payment(false)
  end

  def payment_form

    service = {
      'name' => params['service_name'],
      'amount' => params['amount']
    }
    render inline: get_payment_form(service)

  end

  private

  def update_user_balance

    Payment.create(
      amount: @responce_data[:amount].to_f,
      to_user_id: @responce_data[:user_id],
      from: params['id'][0, 7],
      to: 'user',
      method: params['id']
    )
    wallet = Wallet.find_by(user_id: @responce_data[:user_id])
    
    wallet.update_attributes!(
      main_balance: wallet.main_balance + @responce_data[:amount].to_f
    )
  end

  def prepare_input_data

    send("adapte_#{params[:id]}_data")

  end

  def adapte_liqpay_data

    render :status => 400 if params['data'].blank? || params['signature'].blank? && Rails.env.production?

    liqpay = Liqpay::Liqpay.new
    sign = liqpay.str_to_sign(
     liqpay.instance_values['private_key']  +
     params['data'] +
     liqpay.instance_values['private_key']
    )
    liqpay_data = JSON.parse(Base64.decode64(params['data']))

    render :status => 422 unless Rails.env.development? || params['signature'] == sign
    status_of_payment = liqpay_data['status'] == "wait_accept" ? true : false
    make_responce_data(liqpay_data['customer'], liqpay_data['amount'], liqpay_data['currency'], status_of_payment)

  end

  def adapte_nixmoney_data
    render :status => 422 if params['V2_HASH'] != make_hash_for_ckeck_from(params_for_check(ENV['NIX_MONEY_PASS']))
    make_responce_data(params['user_id'], params['PAYMENT_AMOUNT'], params['PAYMENT_UNITS'], true)
  end

  def adapte_perfectmoney_data
    Rails.logger.debug "params.to_json:"
    Rails.logger.debug params.to_json
    render :status => 422 if params['V2_HASH'] != make_hash_for_ckeck_from(params_for_check(ENV['PERFECT_MONEY_PASS']))
    make_responce_data(params['user_id'], params['PAYMENT_AMOUNT'], params['PAYMENT_UNITS'], true)
  end

  def adapte_advcash_data

    render :status => 400 if params['ac_hash'].blank? && Rails.env.production?

    status_params = [params['ac_transfer']]
    status_params.push(params['ac_start_date'])
    status_params.push(params['ac_sci_name'])
    status_params.push(params['ac_src_wallet'])
    status_params.push(params['ac_dest_wallet'])
    status_params.push(params['ac_order_id'])
    status_params.push(params['ac_amount'])
    status_params.push(params['ac_merchant_currency'])
    status_params.push(ENV['ADV_CASH_PASS'])

    sign = make_hash_for_ckeck_from(status_params, 'SHA256')
    puts "Params\n" +  params.to_json + "\n"
    # puts "Sign\n" +  sign + "\n"

    render :status => 422 unless params['ac_hash'] == sign
    status_of_payment = params['ac_transaction_status'] == "COMPLETED" ? true : false
    make_responce_data(params['user_id'], params['ac_amount'], params['ac_merchant_currency'], status_of_payment)
  end

  def make_responce_data(customer, amount ,currency, status)
    @responce_data = {
        :user_id => customer,
        :amount => amount,
        :currency => currency,
        :success => status
    }
    puts "responce values : " + @responce_data.to_json + "\n"
  end

  def get_payment_form( service )
    if service['name'] == 'liqpay'
      liqpay = Liqpay.new
      liqpay.cnb_form({
      :version      => '3',
      :action       => "pay",
      :amount       => service['amount'],
      :currency     => "UAH",
      :description  => 'No desc yet',
      :customer     => current_user.id.to_s,
      :server_url   => "http://improf.club/finance_api/responce-status/liqpay",
      :result_url   => "http://improf.club/finance_api/success/liqpay",
      :language     => "ru"
      }).html_safe
    end
  end

  def redirect_to_home_after_payment(status)
  	redirect_to home_path, payment_status: status, payment_amount: @responce_data['amount']
  end

  def make_hash_for_ckeck_from values, mode
    puts "String yo encode " + values.join(":")
    # puts '(Digest::' + mode + ".new).digest('" + values.join(":") + "')"
    # exec('(Digest::' + mode + ".new).digest('" + values.join(":") + "')")#.upcase
    
    (Digest::MD5.new).hexdigest(values.join(":")) if mode == 'MD5'
    
    (Digest::SHA256.new).hexdigest(values.join(":")) if mode == 'SHA256'

  end

  def params_for_check(password)
  	#Important to preserve the order.

    params_available = !params['PAYER_ACCOUNT'].nil?
  	if params_available
	  	status_params = [params['PAYMENT_ID']]
	  	status_params.push(params['PAYEE_ACCOUNT'])
	  	status_params.push(params['PAYMENT_AMOUNT'])
	  	status_params.push(params['PAYMENT_UNITS'])
	  	status_params.push(params['PAYMENT_BATCH_NUM'])
	  	status_params.push(params['PAYER_ACCOUNT'])
	  	status_params.push((Digest::MD5.new).hexdigest(password).upcase)
	  	status_params.push(params['TIMESTAMPGMT'])
	  	status_params
	  else
      []
    end
  end
end

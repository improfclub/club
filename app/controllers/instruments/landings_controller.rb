class Instruments::LandingsController < ApplicationController
  before_action :define_landing, only: [:show, :activate, :update_settings]
  before_action :authenticate_user!, only: [:index, :activate]
  before_action :landing_params, only: [:update_settings]
  # OPTIMIZE I'm sure we haven't have to do this
  # before_action :make_payment_services
  # What about this one?
  require "will_paginate/array"
  
  def index
    @for_free = current_user.free_land_number > 0
    @club_links = current_user.club_links
    
    @scopes = %w(my all recent problem)
    unless @scopes.include? params[:type]
      params[:type] = 'all'
      params[:show_modal] = 'index'
    end

    if params[:business_id]
      params[:show_modal] = 'index'
      @landings = Landing.by_business(params[:business_id])
    elsif(params[:type] == 'my')
      @landings = @current_user.landings
    else
      @landings = eval('Landing.' + params[:type])
    end
    @landings = @landings.newest_first.paginate_by params[:page]
  end

  def show
    respond_to do |format|
      format.partial do
        render :partial => 'instruments/landings/detailed_landing.html', :locals => { :user => User.find(params[:id])}
      end
    end
  end

  def activate
    return
    @user = current_user
    @wallet = @user.wallet
    @price = @landing.price.to_f
    empty = current_user.free_land_number > 0

    unless empty or @user.enough? @price
      flash[:notice] = "Недостаточно средств для активации"
      redirect_to action: :index
      return
    end

    if @user.has_landing? @landing
    	flash[:notice] = 'Этот landing page уже активирован'
      redirect_to action: :index
      return
    end

	  link = UserLanding.new
	  keys = [:video_link, :has_vk, :has_ok, :has_fb, :has_youtube]
	  # OPTIMIZE parameters = params.slice(*keys)
	  parameters = {video_link: '', has_fb: true, has_ok: true, has_vk: true, has_youtube: true}

	  link.user_id = @user.id
	  link.landing_id = @landing.id
	  link.activated_at = Time.now
    if empty
      link.is_club = true
      link.reactivate_at = link.activated_at + 5.years
    else
      link.is_club = false
	    link.reactivate_at = link.activated_at + 30.days
    end
	  # TODO Need to generate form for this one
	  link.update_attributes(**parameters)

    unless empty
      unless @user.take_money @price
        flash[:notice] = 'Что-то пошло не так'
        redirect_to action: :index
        return
      end
    end
    unless link.save
      flash[:notice] = 'Что-то пошло не так'
      @user.give_money @price
      redirect_to action: :index
      return
    end
    unless empty
      @user.distribute_money @price
    end

    flash[:notice] = 'Landing page успешно активирован!'
    if params[:business_id].blank?
      redirect_to action: :index 
    else
      redirect_to business_settings_path params[:business_id]
    end
    
  end
  def update_settings
    UserLanding.where(landing_id: params[:id], user_id: current_user.id).first.update_attributes(landing_params)
    redirect_to landings_scope_path('my')
  end
  private
  def landing_params
    params.require(:landing).permit(:video_link)
  end
  def define_landing
    @landing = Landing.find(params[:id])
    # TODO Check for existance?
  end
end

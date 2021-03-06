class CreditCardsController < ApplicationController
  require "payjp"

  def new
    @card = CreditCard.where(user_id: current_user.id)
    redirect_to credit_card_path(current_user.id) if @card.exists?
  end

  def create
    Payjp.api_key = Rails.application.credentials.payjp[:PAYJP_PRIVATE_KEY]
    if params['payjp_token'].blank?
      redirect_to action: "new", alert: "クレジットカードが登録できませんでした。"
    else
      customer = Payjp::Customer.create(
        email: current_user.email,
        card: params["payjp_token"],
        metadata: {user_id: current_user.id}
      )
      @card = CreditCard.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
      
      if @card.save
        redirect_to root_path
      else
        redirect_to action: "create"
      end
    end
  end

  def show
    @card = CreditCard.find_by(user_id: current_user.id)
    if @card.blank?
      redirect_to action: "new"
    else
      Payjp.api_key = Rails.application.credentials.payjp[:PAYJP_PRIVATE_KEY]
      customer = Payjp::Customer.retrieve(@card.customer_id)
      @customer_card = customer.cards.retrieve(@card.card_id)
      @card_brand = @customer_card.brand
      case @card_brand
      when "Visa"
        @card_src = "visa-logo.gif"
      when "MasterCard"
        @card_src = "mastercard-logo.gif"
      when "JCB"
        @card_src = "jcb-logo.gif"
      when "American Express"
        @card_src = "amex-logo.gif"
      when "Diners Club"
        @card_src = "diners-logo.gif"
      when "Discover"
        @card_src = "discover-logo.gif"
      end

      @exp_month = @customer_card.exp_month.to_s
      @exp_year = @customer_card.exp_year.to_s.slice(2,3)
    end
  end

  def destroy
    @card = CreditCard.find_by(user_id: current_user.id)
    if @card.blank?
      redirect_to action: "new"
    else
      Payjp.api_key = Rails.application.credentials.payjp[:PAYJP_PRIVATE_KEY]
      customer = Payjp::Customer.retrieve(@card.customer_id)
      customer.delete
      @card.delete
      if @card.destroy
        redirect_to action: "new"
      else
        redirect_to credit_card_path(current_user.id), alert: "削除できませんでした。"
      end
    end
  end
end

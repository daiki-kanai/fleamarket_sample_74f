# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    @user = User.new
  end

  # POST /resource
  def create
    @user = User.new(sign_up_params)
    unless @user.valid?
      flash.now[:alert] = @user.errors.full_messages
      render :new and return
    end
    session["devise.regist_data"] = {user: @user.attributes}
    session["devise.regist_data"][:user]["password"] = params[:user][:password]
    @identification = @user.build_identification
    render :new_identification
  end

  def create_identification
    @user = User.new(session["devise.regist_data"]["user"])
    @identification = Identification.new(identification_params)
    unless @identification.valid?
      flash.now[:alert] = @identification.errors.full_messages
      render :new_identification and return
    end
    @user.build_identification(@identification.attributes)
    session["identification"] = @identification.attributes
    @deliveryAddress = @user.build_deliveryAddress
    render :new_deliveryAddress
  end

  def create_deliveryAddress
    @user = User.new(session["devise.regist_data"]["user"])
    @identification = Identification.new(session["identification"])
    @deliveryAddress = DeliveryAddress.new(deliveryAddress_params)
    unless @deliveryAddress.valid?
      flash.now[:alert] = @deliveryAddress.errors.full_messages
      render :new_deliveryAddress and return
    end
    @user.build_identification(@identification.attributes)
    @user.build_deliveryAddress(@deliveryAddress.attributes)
    @user.save
    sign_in(:user, @user)
  end


  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def identification_params
    params.require(:identification).permit(:familyName, :firstName, :familyNameKana, :firstNameKana, :birthday)
  end

  def deliveryAddress_params
    params.require(:delivery_address).permit(:familyName, :firstName, :familyNameKana, :firstNameKana, :postCode, :prefecture_id, :city, :address, :buildingName, :telNumber)
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end

class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :authenticate_user!
  def index
    @users = User
              .includes(serialization_options[:include])
              .filter(params)
              .apply_sorts(params[:sort], allowed: [:email, :created_at])
    render json: UserSerializer.new(@users, serialization_options) if stale?(@users)
  end

  def show
    render json: UserSerializer.new(@user, serialization_options) if stale?(@user)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: UserSerializer.new(@user), status: :created, location: [:api, :v1, @user]
    else
      render json: { errors: ErrorSerializer.new(@user) }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: UserSerializer.new(@user)
    else
      render json: { errors: ErrorSerializer.new(@user) }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password)
  end
end

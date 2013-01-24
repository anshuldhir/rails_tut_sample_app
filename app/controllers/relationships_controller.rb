class RelationshipsController < ApplicationController
  before_filter :signed_in_user

  def create
    @user_to_follow = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user_to_follow)
    redirect_to @user_to_follow
  end

  def destroy
    @followed_user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@followed_user)
    redirect_to @followed_user
  end
end
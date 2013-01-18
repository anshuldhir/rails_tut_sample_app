class MicropostsController < ApplicationController
  before_filter :signed_in_user
  before_filter :micropost_owner, only: [:destroy]

  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost posted successfully!"
      redirect_to root_url
    else
      # When rendering for failed micropost creation, we need to 
      # initialize the @feed_items variable required for the 
      # rendering of static_pages/home page.
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to root_url
  end

  private
    def micropost_owner
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
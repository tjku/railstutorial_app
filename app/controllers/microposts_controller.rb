class MicropostsController < ApplicationController

  before_action :signed_in_user
  before_action :correct_user, only: :destroy


  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to root_url
  end


  private

    def micropost_params
      params.require(:micropost).permit(:content)
    end

    def correct_user
      # uses `find_by`, because it returns nil instead of raising an exception when micropost is not found
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end

    # Exception version:
    # def correct_user
    #   @micropsot = current_user.microposts.find(params[:id])
    # rescue
    #   redirect_to root_url
    # end

end


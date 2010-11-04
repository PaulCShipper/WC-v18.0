class StaticController < ApplicationController
  layout CONFIG["layout"] + "bare"
  
  def overloaded
    render :layout => CONFIG["layout"] + "default"
  end
end

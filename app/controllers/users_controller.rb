require 'fastercsv'

class UsersController < ApplicationController
  
  def load_data; end
  
  def flush_data
    User.destroy_all
    flash[:error] = 'Data flushed'
    redirect_to users_path
  end
  
  def select_fields
    @csv_header, @model_fields, random_file_name = User.load_csv(params[:file])
    if @csv_header == false
      flash.now[:error] = @model_fields # this contains the error message
      return render(:action => 'load_data')
    else
      session[:csv_file] = random_file_name
    end
  end
  
  def parse_data
    count = User.parse_csv(session[:csv_file], params[:user])
    session[:csv_file] = nil
    flash[:notice] = "Successfully added #{count} users."
    redirect_to users_path
  end
  
  def index
    @users = User.find(:all)
  end
end
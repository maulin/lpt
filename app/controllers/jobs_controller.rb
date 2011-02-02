class JobsController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /jobs
  # GET /jobs.xml
  def index
    @jobs = Resque::Status.statuses()

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jobs }
    end
  end

  def clear
    Resque::Status.clear
    flash[:notice] = "All jobs cleared."
    redirect_to jobs_path
  end

  def reset_all
    Resque.redis.flushdb
    flash[:notice] = "All jobs/queues/statuses reset."
    redirect_to jobs_path
  end
  
  #def reset_status
  #  hostname = ????
  #  Resque.redis.del(hostname)
  #  flash[:notice] = "Host #{hostnam} reset"
  #  redirect_to jobs_path
  #end

  def destroy
    Resque::Status.kill(params[:id])
    flash[:notice] = "Job sucessfully killed"
    redirect_to jobs_path
  end


end

class JobsController < ApplicationController
  # GET /jobs
  # GET /jobs.xml
  def index
    @jobs = Resque::Status.statuses()

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jobs }
    end
  end


end

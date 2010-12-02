class HostsController < ApplicationController
  # GET /hosts
  # GET /hosts.xml
  def index
    @hosts = Host.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @hosts }
    end
  end

  # GET /hosts/1
  # GET /hosts/1.xml
  def show
    @host = Host.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @host }
    end
  end

  def edit
    @host = Host.find(params[:id])
  end

  def new
    @host = Host.new
  end

  def create
    @host = Host.new(params[:host])
    respond_to do |format|
      if @host.save
        format.html { redirect_to(@host,
                      :notice => 'Host was successfully created.') }
        format.xml  { render :xml => @host,
                      :status => :created, :location => @host }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @host.errors,
                      :status => :unprocessable_entity }
      end
    end
  end

  def update
    @host = Host.find(params[:id])

    respond_to do |format|
      if @host.update_attributes(params[:host])
        format.html { redirect_to(@host,
                      :notice => 'Host was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @host.errors,
                      :status => :unprocessable_entity }
      end
    end
  end  

  def destroy
    if @host.destroy
      respond_to do |format|
        format.html { notice "Successfully destroyed host." }
        format.json { render :json => @host, :status => :ok and return }
      end
    else
      respond_to do |format|
        format.html { error @host.errors.full_messages.join("<br/>") }
        format.json { render :json => @host.errors, :status => :unprocessable_entity and return }
      end
    end
    redirect_to hosts_url
  end

  def scan

    @host = Host.find_by_name("192.168.1.123")
    #Delayed::Job.enqueue ScanHosts.new(@hosts.first,"test","1q2w3e")
    user = "test"
    pass = "1q2w3e"
    Resque.enqueue(ScanHosts, @host.name)

  end
end

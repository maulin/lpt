class HostsController < ApplicationController
  respond_to :html,:json,:yaml
  # GET /hosts
  # GET /hosts.xml
  def index
    @search = Host.search(params[:search])
    @hosts = @search.all
    respond_with(@hosts)
  end

  # GET /hosts/1
  # GET /hosts/1.xml
  def show
    @host = Host.find(params[:id], :include => [{:installations => :package}])

    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @host }
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
        scan(@host)
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

  def scan(*host)
    if host.empty?
      host = Host.find(params[:id])
      Resque.enqueue(ScanHosts, host.name)
      format.html { redirect_to(@host,
                      :notice => "#{host.name} is being scanned for packages. Please refresh the page to view them.") }
    else
      host.each do |h|
        Resque.enqueue(ScanHosts, h.name)
      end
      flash[:notice] = "#{host.size} Hosts are being scanned for packages. Please visit the hosts page to view them"
      redirect_to hosts_path
    end

  end
end

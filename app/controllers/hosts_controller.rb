class HostsController < ApplicationController
  before_filter :find_by_name

  include ActionView::Helpers::TextHelper

  respond_to :html,:json,:yaml
  def index
    @search = Host.includes(:arch, :os).search(params[:search])
    @hosts = @search.all
    respond_with(@hosts)
  end

  def show
    begin
      @host = Host.find_by_name(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "The host you selected doesnt exist!"
      redirect_to hosts_path
    end

    @search = Installation.where(:host_id => @host.id, :currently_installed => 1).includes(:host, :package, :version, :arch).search(params[:search])
    @host_installations = @search.all
    #@host = Host.find_by_name(params[:id])                         
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => [@host, @host_installations] }
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
    if @host.save
      scan(@host)
    else
      render :action => "new"
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
      begin
        host = Host.find_by_name(params[:id])
        Resque.enqueue(ScanHosts, host.name)
        flash[:notice] = "#{host.name} is being scanned for packages. Please refresh the page to view them."
        redirect_to host        
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "The host you selected doesnt exist!"  
        redirect_to hosts_path
      end
    else
      host.each do |h|
        Resque.enqueue(ScanHosts, h.name)
      end
      flash[:notice] = "#{pluralize(host.size, 'Host is', 'Hosts are')} being scanned for packages. Please visit the hosts page to view them."
      redirect_to hosts_path
    end
  end
  
end

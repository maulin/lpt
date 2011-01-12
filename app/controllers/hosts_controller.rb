class HostsController < ApplicationController
  before_filter :find_by_name, :authenticate_user!

  include ActionView::Helpers::TextHelper

  respond_to :html,:json,:yaml
  def index
    @search = Host.includes(:arch, :os).search(params[:search])
    @hosts = @search.all
    respond_with(@hosts)
  end

  def show
    @host = Host.find_by_name(params[:id])
    @arch_split = Installation.select('arches.name, count(*) as count').joins(:arch).where(:host_id => @host.id).group(:arch_id).all
    @repos = Source.where(:host_id => @host.id).joins(:repo).where(:enabled => true).all
    @search = Installation.where(:host_id => @host.id, :currently_installed => 1).includes(:host, :package, :version, :arch).search(params[:search])
    @host_installations = @search.all
    #@host = Host.find_by_name(params[:id])                         
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => {:host_information => @host.to_json(:only => [:name, :running_kernel]), 
                                      :installation => @host_installations.to_json(:only => :installed_on, :include => {:package => {:only => :name},
                                                                                                                        :version => {:only => :name},
                                                                                                                        :arch => {:only => :name}}) } }
    end       
  end

  def edit
    @host = Host.find_by_name(params[:id])
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
    @host = Host.find_by_name(params[:id])

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
      if params[:id]
        host = Host.find_by_name(params[:id]) 
        ScanHosts.create(:hostname => host.name)
        flash[:notice] = "#{host.name} is being scanned for packages. Please refresh the page to view them."
        redirect_to host        
      elsif params[:host_ids]
        ids = params[:host_ids]
        ids.shift if ids[0] == "All"
        ids.each do |id|
          host = Host.find(id) 
          ScanHosts.create(:hostname => host.name)          
        end
        flash[:notice] = "#{pluralize(ids.size, 'Host is', 'Hosts are')} being scanned for packages."
        redirect_to hosts_path        
      end
    else
      host.each do |h|
        ScanHosts.create(:hostname => h.name)
      end
      flash[:notice] = "#{pluralize(host.size, 'Host is', 'Hosts are')} being scanned for packages. Please visit the hosts page to view them."
      redirect_to hosts_path
    end
  end
  
end

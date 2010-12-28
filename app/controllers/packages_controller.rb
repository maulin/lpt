class PackagesController < ApplicationController
  before_filter :find_by_name

  respond_to :html,:json,:yaml

  def index
    @search = Package.pkg_hosts.search(params[:search])
    @packages = @search.all
    #respond_with(@packages)

    respond_to do |format|
      format.html
      format.json do
        @pkg_ver_ids = {}
        @pkg_ver_ids["pkg_ids"]=[]
        @pkg_ver_ids["ver_ids"]=[]
        @packages.each { |p|
          #debugger
          @pkg_ver_ids["pkg_ids"] << p.id
          @pkg_ver_ids["ver_ids"] << p.version_ids
        }
        #debugger
        @search_new = Installation.select("packages.name as \"Package\", hosts.name as \"Host\", versions.name as \"Version\"")\
        .joins(:version,:host,:package).where(:package_id => @pkg_ver_ids["pkg_ids"], :version_id => @pkg_ver_ids["ver_ids"].flatten)

        @installs = @search_new.all
        render :json => @installs
      end
    end
  end

  def show
    #@package = Package.where(:id => params[:id])
    #@search = Package.pkg_hosts.search(params[:search])
    @package = Package.find_by_name(params[:id])
    if @package.nil?
      begin
        raise ActiveRecord::RecordNotFound
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "The package you selected doesnt exist!"
        redirect_to packages_path    
      end
    else
      @search = Installation.select('name, count(host_id) as host_count').joins(:version).where(:package_id => @package.id).group('name')
      @installs = @search.all
      respond_to do |format|
        format.html # show.html.erb
        format.json  { 
          @search = Installation.select("hosts.name as \"Host\", versions.name as \"Version\", arches.name as \"Arch\" " ).joins(:version,:host,:package,:arch).where(:package_id => @package.id, :version_id => @package.version_ids)
          @installs = @search.all
          render :json => [@package, @installs]
        }
      end    
    end          
  end

  def new
    @package = Package.new
  end

  def create
    @package = Package.new(params[:package])
    if @package.save
      flash[:notice] = "Package successfully created."
      redirect_to @package
    else
      render :action => 'new'
    end
  end

=begin Not sure if we need these methods right now.
  def edit
    @package = Package.find_by_name(params[:id])
  end

  def update
    @package = Package.find_by_name(params[:id])
    if @package.update_attributes(params[:package])
      flash[:notice] = "Successfully updated package."
      redirect_to @package
    else
      render :action => 'edit'
    end
  end

  def destroy
    @package = Package.find_by_name(params[:id])
    @package.destroy
    flash[:notice] = "Successfully destroyed package."
    redirect_to packages_url
  end
=end  

end

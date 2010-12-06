class PackagesController < ApplicationController
  def index
    @search = Package.search(params[:search])
#    @packages = @search.all
#    @counter = Package.count(:conditions => {:id => @packages.map(&:id)}, :group => :package_id, :joins => :installations)
     @packages = Package.find_uniq_hosts_installed_on
  end

  def show
    @package = Package.find(params[:id])
    @installs = @package.installations.group(:id, :package_id, :version, :os, :arch).select('id, package_id, version, os, arch, count(*) as host_count')
#    @package = Package.find(params[:id])
#    @counter = @package.installations.size
  end

  def new
    @package = Package.new
  end

  def create
    @package = Package.new(params[:package])
    if @package.save
      flash[:notice] = "Successfully created package."
      redirect_to @package
    else
      render :action => 'new'
    end
  end

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
end

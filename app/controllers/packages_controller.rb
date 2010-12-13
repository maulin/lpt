class PackagesController < ApplicationController

  def index
    @search = Package.pkg_hosts.search(params[:search])
    @packages = @search.all
  end

  def show
    @package = Package.where(:id => params[:id])
    if @package.size == 0
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
        format.json  { render :json => @installs }
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

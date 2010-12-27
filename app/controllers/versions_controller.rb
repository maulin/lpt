class VersionsController < ApplicationController
  before_filter :find_by_name

  respond_to :html,:json,:yaml

  def index
    @search = Version.search(params[:search])
    @versions = @search.all
    respond_with(@versions)
  end

  def show
    #@version = Version.where(:id => params[:id])
    @version = Version.find_by_name(params[:id])
    if @version.nil?
      begin
        raise ActiveRecord::RecordNotFound
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "The version you selected doesnt exist!"
        redirect_to versions_path    
      end
    else
      @search = Installation.select('name, count(host_id) as host_count').joins(:version).where(:version_id => @version.id).group('name')
      @installs = @search.all
      respond_to do |format|
        format.html # show.html.erb
        format.json  { 
          @search = Installation.select("hosts.name as #{@version.name}").joins(:version,:host,:version).where(:version_id => @version.id, :version_id => @version.version_ids)
          @installs = @search.all
          render :json => @installs
        }
      end    
    end          
  end

  def new
    @version = version.new
  end

  def create
    @version = Persion.new(params[:version])
    if @version.save
      flash[:notice] = "version successfully created."
      redirect_to @version
    else
      render :action => 'new'
    end
  end
#
#  # PUT /versions/1
#  # PUT /versions/1.xml
#  def update
#    @version = Version.find(params[:id])
#
#    respond_to do |format|
#      if @version.update_attributes(params[:version])
#        format.html { redirect_to(@version, :notice => 'Version was successfully updated.') }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @version.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  # DELETE /versions/1
#  # DELETE /versions/1.xml
#  def destroy
#    @version = Version.find(params[:id])
#    @version.destroy
#
#    respond_to do |format|
#      format.html { redirect_to(versions_url) }
#      format.xml  { head :ok }
#    end
#  end
end

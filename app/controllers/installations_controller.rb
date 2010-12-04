class InstallationsController < ApplicationController

  def show
    @package = Package.find(params[:package_id])
    @version = params[:version]
    @hosts = Installation.joins(:host).where(:version => @version, :package_id => @package.id).select('DISTINCT hosts.name, installed_on')
  end

end

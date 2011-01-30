class ReposController < ApplicationController

  def index
    @search = Repo.search(params[:search])
    @repo = @search.all
  end

  def show
    @repo = Repo.find_by_name(params[:id])
    @sources = Source.select('*, count(host_id) as host_count').group(:host_id).where(:repo_id => @repo.id).joins(:repo)
  end
  
  def scan(*repos)
    flash[:notice] = "Scanning repo..."
    @repo = Repo.find_by_name(params[:id])
    ScanRepos.create(:url => @repo.url)
    redirect_to repo_path(@repo)
  end

end

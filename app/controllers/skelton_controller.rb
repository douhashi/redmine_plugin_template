class SkeltonController < ApplicationController
  before_action :find_project, :authorize, :except => [:index]
  
  def index
    @skelton_items = []
  end

  def show
    @skelton_item = params[:id]
  end

  def new
    @skelton_item = {}
  end

  def create
    redirect_to :action => 'index', :project_id => @project
  end

  def edit
    @skelton_item = params[:id]
  end

  def update
    redirect_to :action => 'show', :id => params[:id], :project_id => @project
  end

  def destroy
    redirect_to :action => 'index', :project_id => @project
  end

  private

  def find_project
    @project = Project.find(params[:project_id]) if params[:project_id]
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
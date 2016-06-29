# Redmine Announcements plugin controller
class AnnouncementsController < ApplicationController
  unloadable

  before_filter :find_project, :except => [:hide_announcement]
  before_filter :set_timezone, :only => [:new, :edit]
  before_filter :set_timevalues, :only => [:create, :update]

  def index
    @announcements = Announcement.where(:project_id => @project)
  end

  def hide_announcement
    session[:announcement_hide_time] = Time.now
    respond_to do |format|
      format.html { redirect_to request.referer }
      format.js
    end
  end


  def new
    @announcement = Announcement.new
  end

  def create
    attributes = {
      message: params[:announcement][:message],
      starts_at: @starts_at,
      ends_at: @ends_at
    }
    @announcement = Announcement.new(attributes.merge({:project_id => @project.id}))

    if @announcement.save
      redirect_to announcements_path(:project_id => params[:project_id]), :notice => l(:label_announcement_created)
    else
      render :new, :notice => l(:label_error)
    end
  end

  def show
    @announcement = Announcement.find(params[:id])
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def update
    @announcement = Announcement.find(params[:id])
    attributes = {
      message: params[:announcement][:message],
      starts_at: @starts_at,
      ends_at: @ends_at
    }
    if @announcement.update(attributes)
      redirect_to announcements_url(:project_id => params[:project_id]), :notice => l(:label_announcement_updated)
    else
      render :action => "edit"
    end

  end

  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy

    redirect_to announcements_url(:project_id => params[:project_id])
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def set_timezone
    # User.current.time_zone #=> 'London'
    Time.zone = User.current.time_zone
  end

  def time_value(hash, field)
    Time.zone.local(*(1..5).map { |i| hash["#{field}(#{i}i)"] })
  end

  def set_timevalues
    @starts_at = time_value(params[:announcement], 'starts_at')
    @ends_at = time_value(params[:announcement], 'ends_at')
  end
end

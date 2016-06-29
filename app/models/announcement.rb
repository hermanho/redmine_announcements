class Announcement < ActiveRecord::Base
  unloadable

  validates_presence_of :message, :message => l(:label_blank)

  def self.current_announcements(hide_time,project)
    Announcement.where( ["starts_at <= now() AND ends_at >= now() AND project_id = ?", project] ).scoping do
      if hide_time.nil?
        Announcement.all
      else
        Announcement.where( [ "updated_at > ? OR starts_at > ?", hide_time, hide_time])
      end
    end
  end


end

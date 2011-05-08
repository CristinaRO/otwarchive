class InboxMessage < ActiveRecord::Base
  # validates_presence_of :user_id
  
  belongs_to :user
  # belongs_to :recipient, :class_name => 'User'
  belongs_to :messageable, :polymorphic => true
  
  # Filters inbox comments by read and/or replied to and sorts by date
  scope :find_by_filters, lambda { |filters| 
    read = case filters[:read]
      when 'true' then true
      when 'false' then false
      else [true, false]
    end
    replied_to = case filters[:replied_to]
      when 'true' then true
      when 'false' then false
      else [true, false]
    end
    { :order => 'created_at ' + (filters[:date] || 'DESC'),
      :conditions => {:read => read, :replied_to => replied_to}}
  }
  
  # Gets the number of unread comments
  def self.count_unread
    self.count(:conditions => {:read => false})
  end

end
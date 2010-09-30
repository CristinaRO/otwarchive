class Comment < ActiveRecord::Base
  belongs_to :pseud         
  belongs_to :commentable, :polymorphic => true
  belongs_to :parent, :polymorphic => true

  has_many :inbox_comments, :foreign_key => 'feedback_comment_id', :dependent => :destroy
  has_many :users, :through => :inbox_comments
 
  validates_presence_of :name, :email, :unless => :pseud_id
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :create, :unless => :pseud_id
  validates :email, :email_veracity => true, 
    :message => t('invalid_email', :default => 'does not seem to be valid.'), 
    :timeout => 0.5

  validates_presence_of :content
  validates_length_of :content, 
    :maximum => ArchiveConfig.COMMENT_MAX, 
    :too_long => t('invalid_content_length', :default => "must be less than %{count} letters long.", :count => ArchiveConfig.COMMENT_MAX)

  def validate
    errors.add_to_base(t('invalid_spam', :default => "This comment looks like spam to our system, sorry! Please try again, or create an account to comment.")) unless check_for_spam
  end
  
  scope :recent, lambda { |*args| {:conditions => ["created_at > ?", (args.first || 1.week.ago.to_date)]} }
  scope :limited, lambda {|limit| {:limit => limit.kind_of?(Fixnum) ? limit : 5} }
  scope :ordered_by_date, :order => "created_at DESC"
  scope :top_level, :conditions => ["commentable_type in (?)", ["Chapter", "Bookmark"]]
  scope :include_pseud, :include => :pseud
  scope :not_deleted, :conditions => {:is_deleted => false}
  
  # Gets methods and associations from acts_as_commentable plugin
  acts_as_commentable
  has_comment_methods 
  
  def akismet_attributes
    {
      :key => ArchiveConfig.AKISMET_KEY,
      :blog => ArchiveConfig.AKISMET_NAME,
      :user_ip => ip_address,
      :user_agent => user_agent,
      :comment_author => name,
      :comment_author_email => email,
      :comment_content => content
    }
  end
  
  before_create :set_depth
  before_create :set_thread_for_replies
  before_create :set_parent
  after_create :update_thread
  before_create :adjust_threading, :if => :reply_comment?
  
  # Set the depth of the comment: 0 for a first-class comment, increasing with each level of nesting
  def set_depth
    self.depth = self.reply_comment? ? self.commentable.depth + 1 : 0
  end
  
  # The thread value for a reply comment should be the same as its parent comment
  def set_thread_for_replies
    self.thread = self.commentable.thread if self.reply_comment?
  end
  
  # Save the ultimate parent
  def set_parent
    self.parent = self.reply_comment? ? self.commentable.parent : self.commentable
  end
  
  # We need a unique thread id for replies, so we'll make use of the fact
  # that ids are unique
  def update_thread
    self.update_attribute(:thread, self.id) unless self.thread
  end
  
  def adjust_threading
    self.commentable.add_child(self)
  end
  
  # Is this a first-class comment?
  def top_level?
    !self.reply_comment?
  end
  
  def comment_owner
    if self.pseud.nil?
      nil
    else
      return self.pseud.user
    end
  end
  
  def comment_owner_name
    if self.pseud.nil?
      self.name
    else
      self.pseud.name
    end
  end
  
  def comment_owner_email
    if self.pseud.nil? 
      self.email
    else
      self.pseud.user.email
    end
  end
  
  # override this method from commentable_entity.rb
  # to return the name of the ultimate parent this is on
  # we have to do this somewhat roundabout because until the comment is
  # set and saved, the ultimate_parent method will not work (the thread is not set)
  # and this is being called from before then. 
  def commentable_name
    self.reply_comment? ? self.commentable.ultimate_parent.commentable_name : self.commentable.commentable_name
  end
  
  # override this method from comment_methods.rb to return ultimate
  alias :original_ultimate_parent :ultimate_parent 
  def ultimate_parent
    myparent = self.original_ultimate_parent
    myparent.kind_of?(Chapter) ? myparent.work : myparent
  end

  def self.commentable_object(commentable)
    commentable.kind_of?(Work) ? commentable.last_chapter : commentable
  end
  
  def find_all_comments
    self.all_children
  end
  
  def count_all_comments
    self.children_count
  end
  
  def count_visible_comments
    self.children_count #FIXME
  end    
  
  def check_for_spam
    #don't check for spam if the comment is 'signed'
    self.approved = !self.pseud_id.nil? || !Akismetor.spam?(akismet_attributes)
  end
  
  #don't want to submit anything to Akismet while testing. bad things might happen
  def mark_as_spam!
    update_attribute(:approved, false)
    Akismetor.submit_spam(akismet_attributes)
  end

  def mark_as_ham!
    update_attribute(:approved, true)
    #Akismetor.submit_ham(akismet_attributes)
  end
end

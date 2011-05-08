class RenameInboxCommentToInboxMessage < ActiveRecord::Migration
  def self.up
    rename_table :inbox_comments, :inbox_messages
    rename_column :inbox_messages, :feedback_comment_id, :messageable_id
    add_column :inbox_messages, :messageable_type, :string, {:limit => 100}
  end

  def self.down
  end
end

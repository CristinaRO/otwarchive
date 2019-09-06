class ChangeKudosIdType < ActiveRecord::Migration[5.1]
  def up
    change_column :kudos, :id, "bigint NOT NULL AUTO_INCREMENT"

    remove_index :kudos, [:commentable_id, :commentable_type, :pseud_id]
    add_index :kudos, [:commentable_id, :commentable_type, :pseud_id], unique: true
  end

  def down
  end
end

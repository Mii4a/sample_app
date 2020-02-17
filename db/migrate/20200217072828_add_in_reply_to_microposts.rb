class AddInReplyToMicroposts < ActiveRecord::Migration[5.1]
  def change
    add_column :microposts, :in_reply_to, :integer
  end
end

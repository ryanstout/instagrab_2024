class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, if_not_exists: true do |t|
      t.text :email_prefix
      t.text :email
      t.text :full_name
      t.text :password
      t.integer :state, default: 0
      t.integer :proxy_id

      t.timestamps
    end
  end
end

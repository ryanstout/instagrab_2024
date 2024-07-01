class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles, if_not_exists: true do |t|
      t.string :profile_name, null: false
      t.boolean :pulled, default: false

      t.timestamps
    end
  end
end

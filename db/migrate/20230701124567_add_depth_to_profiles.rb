class AddDepthToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :depth, :integer, default: 0
  end
end

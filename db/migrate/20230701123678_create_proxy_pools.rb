class CreateProxyPools < ActiveRecord::Migration[7.1]
  def change
    create_table :proxy_pools, if_not_exists: true do |t|
      t.text :proxy, null: false
      t.text :timezone_str
      t.integer :state, default: 0

      t.timestamps
    end
  end
end

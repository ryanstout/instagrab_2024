class AddDevToProxyPools < ActiveRecord::Migration[7.1]
  def change
    add_column :proxy_pools, :dev, :boolean, default: false
  end
end

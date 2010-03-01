class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.boolean :enable
      t.text :desc
      t.integer :phone

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

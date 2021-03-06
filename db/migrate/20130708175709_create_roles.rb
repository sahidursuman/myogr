class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
    end

    create_table :roles_users do |t|
      t.belongs_to :user
      t.belongs_to :role
    end
  end
end

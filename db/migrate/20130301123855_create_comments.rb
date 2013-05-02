class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :dhis2_mapping_id
      t.text :text

      t.timestamps
    end
  end
end

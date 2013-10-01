Sequel.migration do
  up do
    create_table(:links) do
      primary_key :id
      String :item_id, :null => false
      String :url, :null => false
      String :given_title, :text => true
      String :resolved_title, :text => true
      Boolean :favorite
      String :excerpt, :text => true
      String :tags
      String :authors
      String :content, :text => true
      foreign_key :user_id, :users
      index :user_id
    end
  end

  down do
    drop_table(:links)
  end
end

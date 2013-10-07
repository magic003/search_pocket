Sequel.migration do
  up do
    add_column :users, :since, String, :default => nil
  end

  down do
    drop_column :users, :since
  end
end

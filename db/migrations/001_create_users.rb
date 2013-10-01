Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :name, :null => false
      String :token, :null => false
      DateTime :register_at, :null => false
      DateTime :login_at, :null => false
    end
  end

  down do
    drop_table(:users)
  end
end

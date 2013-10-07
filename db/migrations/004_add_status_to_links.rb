Sequel.migration do
  up do
    # 1 is parsed, -1 is error
    add_column :links, :status, Integer, :default => 0
  end

  down do
    drop_column :links, :status
  end
end

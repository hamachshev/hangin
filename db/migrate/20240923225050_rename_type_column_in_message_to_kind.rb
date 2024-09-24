class RenameTypeColumnInMessageToKind < ActiveRecord::Migration[7.0]
  def change
    rename_column :messages, :type, :kind
  end
end

defmodule Demo.Repo.Migrations.DoNotAllowNulls do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      modify :value, :string, null: false
    end
  end
end

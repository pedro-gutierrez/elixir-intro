defmodule Demo.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :key, :string
      add :version, :integer
      add :value, :string

      timestamps()
    end

  end
end

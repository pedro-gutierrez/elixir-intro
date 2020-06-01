defmodule Demo.Repo.Migrations.SetPrimaryKey do
  use Ecto.Migration

  def change do
    drop table(:entries)

    create table(:entries, primary_key: false) do
      add :key, :string, primary_key: true
      add :version, :integer, primary_key: true
      add :value, :string

      timestamps()
    end
  end
end

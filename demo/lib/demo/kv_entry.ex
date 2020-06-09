defmodule Demo.KvEntry do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias Demo.Repo

  @primary_key false

  schema "entries" do
    field :key, :string, primary_key: true
    field :version, :integer, primary_key: true
    field :value, :string

    timestamps()
  end

  @doc false
  def changeset(kv_entry, attrs) do
    kv_entry
    |> cast(attrs, [:key, :version, :value])
    |> validate_required([:key, :version, :value])
    |> unique_constraint(:version, name: :entries_pkey)
  end

  @doc """
  Fetch all versions for the given key
  from the database. Sort them in 
  descendent order (newer versions first)
  """
  def read(key) do
    from(e in __MODULE__,
      where: e.key == ^key,
      order_by: [desc: :version]
    )
    |> Repo.all()
    |> Enum.map(fn %__MODULE_{version: version, value: value} ->
      {version, value}
    end)
  end

  def write(key, version, value) do
    case :rand.uniform(3) do
      3 ->
        2 = 3

      _ ->

        %__MODULE__{}
        |> changeset(%{key: key, version: version, value: value})
        |> Repo.insert()
    end
  end

  def delete(key) do
    {_, _} = from(e in __MODULE__, where: e.key == ^key)
             |> Repo.delete_all()
    :ok
  end
end

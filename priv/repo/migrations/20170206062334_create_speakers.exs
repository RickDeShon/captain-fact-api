defmodule CaptainFact.Repo.Migrations.CreateSpeaker do
  use Ecto.Migration

  def change do
    create table(:speakers) do
      add :full_name, :citext, null: false
      add :title, :string
      add :is_user_defined, :boolean, null: false
      add :picture, :string
      add :is_removed, :boolean, null: false, default: false

      timestamps()
    end
    create index(:speakers, [:full_name], where: "is_user_defined = false")
  end
end

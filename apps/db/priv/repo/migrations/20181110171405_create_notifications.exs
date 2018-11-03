defmodule DB.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def up do
    DB.Type.NotificationType.create_type()

    create table(:notifications) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:action_id, references(:users_actions, on_delete: :delete_all), null: false)
      add(:type, :notification_type, null: false)
      add(:seen, :boolean, null: false, default: false)
    end

    create(index(:notifications, :user_id))
  end

  def down do
    DB.Type.NotificationType.drop_type()
    drop(index(:notifications, :user_id))
    drop(table(:subscriptions))
  end
end

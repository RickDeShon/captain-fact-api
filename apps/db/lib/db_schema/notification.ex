defmodule DB.Schema.Notification do
  @moduledoc """
  Represent a user's Notification.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    belongs_to(:user, DB.Schema.User)
    belongs_to(:action, DB.Schema.UserAction)

    field(:type, DB.Type.NotificationType, null: false)
    field(:seen, :boolean, default: false, null: false)
  end

  @fields [:user_id, :action_id, :type, :seen]
  @required_fields [:user_id, :action_id, :type]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end

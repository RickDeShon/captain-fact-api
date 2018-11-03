defmodule CF.Notifications.NotificationBuilder do
  @moduledoc """
  A module to build Notification from various inputs.
  """

  alias DB.Schema.Subscription
  alias DB.Schema.UserAction
  alias DB.Schema.Notification
  alias DB.Type.NotificationType

  @doc """
  Return `Notification` params to put in a changeset for given action and
  subscription. For self user actions like :email_confirmed on :unlock_achievement
  this
  """
  @spec for_subscribed_action(UserAction.t(), Subscription.t()) :: Notification.t()
  def for_subscribed_action(action, subscription) when not is_nil(subscription) do
    %{
      user_id: subscription.user_id,
      action_id: action.id,
      type: notification_type(subscription, action)
    }
  end

  @spec notification_type(UserAction.t()) :: NotificationType.t()
  def notification_type(subscription, action_type),
    do: :xxx

  def notification_type(%{type: :email_confirmed}),
    do: :email_confirmed
end

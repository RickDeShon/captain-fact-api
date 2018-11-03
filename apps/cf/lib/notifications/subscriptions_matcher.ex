defmodule CF.Notifications.SubscriptionsMatcher do
  @moduledoc """
  Matches actions with subscriptions. This module is how we know which user
  should be notified when a specific action is made.
  """

  alias DB.Schema.Subscription
  alias DB.Schema.UserAction

  @doc """
  Takes an action, check for subscriptions, returns a list of `Subscription`
  watching this.

  In case multiple subscriptions match for the same user, only returns the more
  accurate one (in order, Comment - Statemement - Video).
  """
  @spec match_action(UserAction.t()) :: [Subscription.t()]
  def match_action(action) do
  end
end

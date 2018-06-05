defmodule DB.Schema.User do
  @moduledoc """
  Represent a user that can login on the website. Users can be marked as
  `publisher` which allow them to post videos without limitations.
  """

  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias DB.Type.{Achievement, UserPicture}
  alias DB.Schema.{UserAction, Comment, Vote, Flag}


  schema "users" do
    field :username, :string
    field :email, :string
    field :encrypted_password, :string
    field :name, :string
    field :picture_url, UserPicture.Type
    field :reputation, :integer, default: 0
    field :today_reputation_gain, :integer, default: 0
    field :locale, :string
    field :achievements, {:array, :integer}, default: []
    field :newsletter, :boolean, default: true
    field :newsletter_subscription_token, :string
    field :is_publisher, :boolean, default: false
    field :completed_onboarding_steps, {:array, :integer}, default: []

    # Social networks profiles
    field :fb_user_id, :string

    # Email Confirmation
    field :email_confirmed, :boolean, default: false
    field :email_confirmation_token, :string

    # Virtual
    field :password, :string, virtual: true

    # Assocs
    has_many :actions, UserAction, on_delete: :nilify_all
    has_many :comments, Comment, on_delete: :delete_all
    has_many :votes, Vote, on_delete: :delete_all

    has_many :flags_posted, Flag, foreign_key: :source_user_id, on_delete: :delete_all

    timestamps()
  end

  def user_appelation(%{username: username, name: nil}), do: "@#{username}"
  def user_appelation(%{username: username, name: name}), do: "#{name} (@#{username})"

  @email_regex ~r/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  @valid_locales ~w(en fr)
  @required_fields ~w(email username)a
  @optional_fields ~w(name password locale)a

  def email_regex(), do: @email_regex

  @doc """
  Creates a changeset based on the `model` and `params`.
  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> common_changeset(params)
    |> validate_length(:password, min: 6, max: 256)
    |> put_encrypted_pw
  end

  @doc"""
  Generate a changeset to update `reputation` and `today_reputation_gain` without verifying daily limits
  """
  def reputation_changeset(model = %{reputation: reputation, today_reputation_gain: today_gain}, change)
  when is_integer(change) do
    change(model, %{reputation: reputation + change, today_reputation_gain: today_gain + change})
  end
  def reputation_changeset(model, 0) do
    change(model)
  end

  def registration_changeset(model, params \\ %{}) do
    model
    |> common_changeset(params)
    |> password_changeset(params)
    |> generate_email_verification_token(false)
    |> put_change(:achievements, [Achievement.get(:welcome)]) # Default to "welcome" achievement
  end

  def changeset_confirm_email(model, is_confirmed) do
    model
    |> change(email_confirmed: is_confirmed)
    |> generate_email_verification_token(is_confirmed)
  end

  def password_changeset(model, params) do
    model
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 256)
    |> put_encrypted_pw
  end

  def provider_changeset(model, params \\ %{}) do
    cast(model, params, [:fb_user_id])
  end

  def changeset_achievement(model, achievement) do
    updated_achievements = if achievement in model.achievements,
      do: model.achievements,
      else: Enum.uniq([achievement | model.achievements])

    Ecto.Changeset.change(model, achievements: updated_achievements)
  end

  @spec changeset_completed_onboarding_step(%__MODULE__{}, integer)::Changeset.t
  def changeset_completed_onboarding_step(model, completed_oboarding_step) do
    updated_completed_onboarding_steps =
      [completed_oboarding_step | model.completed_onboarding_steps]
      |> Enum.uniq

    model
    |> change(completed_onboarding_steps: updated_completed_onboarding_steps)
    |> validate_subset(:completed_onboarding_steps, 0..30)
  end

  @token_length 32
  defp generate_email_verification_token(changeset, false),
    do: put_change(
      changeset,
      :email_confirmation_token,
      DB.Utils.TokenGenerator.generate(@token_length)
    )

  defp generate_email_verification_token(changeset, true),
    do: put_change(changeset, :email_confirmation_token, nil)

  defp common_changeset(model, params) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> update_change(:username, &String.trim/1)
    |> update_change(:name, &format_name/1)
    |> validate_length(:username, min: 5, max: 15)
    |> validate_length(:name, min: 2, max: 20)
    |> validate_email()
    |> validate_locale()
    |> validate_username()
    |> validate_format(:name, ~r/^[^0-9!*();:@&=+$,\/?#\[\].\'\\]+$/)
  end

  defp put_encrypted_pw(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        changeset
        |> put_change(:encrypted_password, Bcrypt.hash_pwd_salt(pass))
        |> delete_change(:password)
      _ ->
        changeset
    end
  end

  def validate_email(changeset = %{changes: %{email: email}}) do
    case Regex.match?(@email_regex, email) do
      true ->
        case Burnex.is_burner?(email) do
          true -> add_error(changeset, :email, "forbidden_provider")
          false -> changeset
        end
      false -> add_error(changeset, :email, "invalid_format")
    end
  end
  def validate_email(changeset), do: changeset

  @doc"""
  Validate locale change by checking for `locale` in `changes` key. If locale
  is invalid or unknown, it will be set to the default (en).
  """
  def validate_locale(changeset = %{changes: %{locale: _}}) do
    changeset = update_change(changeset, :locale, &String.downcase/1)
    if changeset.changes.locale in @valid_locales do
      changeset
    else
      put_change(changeset, :locale, "en")
    end
  end

  def validate_locale(changeset), do: changeset

  @forbidden_username_keywords ~w(captainfact captain admin newuser temporary anonymous)
  @username_regex ~r/^[a-zA-Z0-9-_]+$/ # Only alphanum, '-' and '_'
  defp validate_username(changeset = %{changes: %{username: username}}) do
    lower_username = String.downcase(username)
    case Enum.find(@forbidden_username_keywords, &String.contains?(lower_username, &1)) do
      nil ->
        validate_format(changeset, :username, @username_regex)
      keyword ->
        add_error(changeset, :username, "contains a foridden keyword: #{keyword}")
    end
  end
  defp validate_username(changeset), do: changeset

  # Format name

  defp format_name(nil),
    do: nil

  defp format_name(name) do
    name
    |> String.replace(~r/ +/, " ")
    |> String.trim()
  end
end

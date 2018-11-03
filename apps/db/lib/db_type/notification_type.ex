import EctoEnum

defenum(
  DB.Type.NotificationType,
  :notification_type,
  [
    :reply_to_comment,
    :new_comment,
    :new_source,
    :new_statement,
    :new_achievement,
    :email_confirmed
  ]
)

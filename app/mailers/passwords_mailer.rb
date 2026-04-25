class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: t('auth.mailers.passwords.subject'), to: user.email_address
  end
end

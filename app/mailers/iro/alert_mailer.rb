
class Iro::AlertMailer < ActionMailer::Base
  default from: 'no-reply@wasya.co'
  layout 'mailer'

  def stock_alert alert
    @alert = alert
    mail( to: 'poxlovi@gmail.com',
      subject: 'Iro::AlertMailer#stock_alert' )
  end

end

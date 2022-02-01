
module Warbler
  class ApplicationMailer < ActionMailer::Base
    default from: '314658@gmail.com'
    layout 'mailer'

    def stock_alert stock
      @stock = stock
      mail( :to => stock.profile.email, :subject => "IshManager Stock Alert :: #{stock.ticker}" ).deliver
    end

    # def condor_followup_alert args
    #   @condor = Ish::IronCondor.find args[:condor_id]
    #   @args = args
    #   mail( to: 'piousbox@gmail.com', subject: "Condor Followup Alert :: #{condor.ticker} #{args.to_s}" ).deliver
    # end

  end
end

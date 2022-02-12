require "spec_helper"

RSpec.describe IshManager::ApplicationMailer, :type => :mailer do
  describe "#shared_galleries" do
    before do
      DatabaseCleaner.clean
    end

    let(:profile) {
      create(:user_profile) }
    let(:gallery) { create(:gallery) }
    let(:mail) do
      IshManager::ApplicationMailer.shared_galleries([profile], gallery)
    end

    it "renders the headers" do
      expect(mail.subject).to eq("You got new shared galleries on pi manager")
      expect(mail.bcc).to eq([ profile.email ])
      expect(mail.from).to eq(["314658@gmail.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("This gallery has been newly shared with you on pi manager:")
    end
  end
end

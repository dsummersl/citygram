require 'spec_helper'

describe Citygram::Workers::SubscriptionConfirmation do
  subject { Citygram::Workers::SubscriptionConfirmation.new }

  context 'sms' do
    let!(:subscription) { create(:subscription, channel: 'sms', contact: '212-555-1234') }

    before do
      stub_request(:post, "https://dev-account-sid:dev-auth-token@api.twilio.com/2010-04-01/Accounts/dev-account-sid/Messages.json").
        with(body: {
          "Body"=>"You are now subscribed to #{subscription.publisher.title}... Woohoo!",
          "From"=>"15555555555",
          "To"=>"212-555-1234"}).
        to_return(status: 200, body: {
          'sid' => 'SM10ea1dce707f4bedb44204c9fbc02e39',
          'to' => subscription.contact,
          'from' => '15555555555',
          'body' => "You are now subscribed to #{subscription.publisher.title}... Woohoo!",
          'status' => 'queued'
        }.to_json)
    end

    it 'retrieves the subscription of interest' do
      expect(Subscription).to receive(:first!).with(id: subscription.id).and_return(subscription)
      subject.perform(subscription.id)
    end
  end
end
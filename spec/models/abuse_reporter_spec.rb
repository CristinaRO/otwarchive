require 'spec_helper'

describe AbuseReporter do
  let(:abuse_reporter) { AbuseReporter.new(title: 'This is wrong') }

  describe '#request_body' do
    it 'includes the required fields' do
      expect(abuse_reporter.request_body).to be_a_hash_including(subject: 'This is wrong')
    end
  end
end

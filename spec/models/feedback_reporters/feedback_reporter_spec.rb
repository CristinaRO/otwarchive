require "spec_helper"

describe FeedbackReporter do
  include ZohoClientSpecHelper

  let(:generic_report_attributes) do
    {
      title: "This is a tragesy",
      description: "Nothing more to say",
      language: "English",
      email: "walrus@example.org",
      username: "Walrus",
    }
  end

  let(:expected_ticket_attributes) do
    {
      "email" => "walrus@example.org",
      "contactId" => "1",
      "cf" => {
        "Language" => "English",
      }
    }
  end

  before(:each) do
    stub_zoho_auth_client
    stub_zoho_resource_client
  end

  let(:subject) { FeedbackReporter.new(generic_report_attributes) }

  describe "#title" do
    it "strips html breaks" do
      generic_report_attributes.merge!(title: "  No breaks here  ")

      expect(subject.title).to eq("No breaks here")
    end
  end

  describe "#description" do
    it "adds breaks between paragraphs" do
      generic_report_attributes.merge!(description: "Bla </p><p> Bla")

      expect(subject.description).to eq("Bla</p><br /><p>Bla")
    end
  end

  describe "#send_report!" do
    it "requests an access token from the Zoho auth client" do
      expect(ZohoAuthClient).to receive_message_chain(:new, :access_token)

      subject.send_report!
    end

    it "calls the Zoho ticket creator with the expected arguments" do
      expect(ZohoResourceClient).to receive_message_chain(:new, :create_ticket)
        .with(ticket_attributes: expected_ticket_attributes)

      subject.send_report!
    end
  end

  describe "#report_attributes" do
    it "returns the expected attributes" do
      expect(subject.report_attributes).to eq(expected_ticket_attributes)
    end
  end
end

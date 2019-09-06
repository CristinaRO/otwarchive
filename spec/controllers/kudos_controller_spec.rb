require 'spec_helper'

describe KudosController do
  include LoginMacros

  let(:work) { create(:posted_work) }
  let(:user) { create(:user) }
  let(:kudos_params) { { kudo: { commentable_id: work.id, commentable_type: "Work"} } }

  before do
    fake_login_known_user(user)
  end

  before(:each) do
    request.env["HTTP_REFERER"] = "/where_i_came_from"
    allow_any_instance_of(KudosSweeper).to receive(:after_create)
  end

  context "when the logged in user has not left kudos on the work before" do
    it "succeeds" do
      expect {
        post :create, params: kudos_params
      }.to change { work.kudos.count }.by(1)
    end
  end

  context "when the logged in user has already left kudos on the work" do
    before do
      create(:kudo, commentable_id: work.id, pseud: user.default_pseud)
    end

    context "with the same pseud that is their default now" do
      it "fails" do
        expect {
          post :create, params: kudos_params
        }.not_to change { work.kudos.count }
      end

      it "shows the passive-aggressive smiley error" do
        post :create, params: kudos_params

        expect(flash[:comment_error]).to match("You have already left kudos here.")
      end
    end

    context "with a different pseud than their current default pseud" do
      let!(:new_default_pseud) { create(:pseud, user: user, is_default: true) }

      before do
        user.default_pseud.update!(is_default: false)
      end

      it "succeeds" do
        expect(user.default_pseud).to eq(new_default_pseud)
        expect {
          post :create, params: kudos_params
        }.to change { work.kudos.count }.by(1)
      end
    end
  end
end

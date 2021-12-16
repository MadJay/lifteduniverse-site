require 'rails_helper'

RSpec.describe Api::V1::CmsAssetsController, type: :controller do
  describe "GET LiveStreams" do
   it "should get live streams from service" do
      res = Wowza::LiveStreams.call
      expect(res["live_streams"]).to be
   end

   it "should get live stream detail from service" do
    res = Wowza::LiveStreamDetail.call('jjwpbng4')
    expect(res).to be
   end

   it "should get live streams from controller" do
    get :index
    expect(response).to be

    json = JSON.parse(response.body)
    expect(json["live_streams"]).to be_present
   end

   it "should get live stream detail from controller" do
    get :show, params: { id: 'jjwpbng4'}
    expect(response).to be

    #json = JSON.parse(response.body)
    #expect(json["live_streams"]).to be_present
   end

  end
end

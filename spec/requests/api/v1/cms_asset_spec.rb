require 'rails_helper'

RSpec.describe Api::V1::CmsAssetsController, type: :controller do
  describe "GET LiveStreams" do
   it "should get live streams from service" do
      res = Wowza::LiveStreams.call
      expect(res["vod_streams"]).to be
   end

   it "should get live stream detail from service" do
    res = Wowza::LiveStreamDetail.call('z32dc2jv')
    expect(res).to be
   end

   it "should get live streams from controller" do
    get :index
    expect(response).to be

    json = JSON.parse(response.body)
    puts "#{json}"
    expect(json["vod_streams"]).to be

    #id = json['live_streams'].first[:id]

   end

   it "should get live stream detail from controller" do
    get :show, params: { id: 'z32dc2jv'}
    expect(response).to be

    json = JSON.parse(response.body)
    puts "#{json}"
    expect(json["vod_stream"]).to be_present
   end

  end
end

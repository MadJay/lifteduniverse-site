require 'rails_helper'

RSpec.describe "Api::V1::CmsAssetsController", type: :request do
  describe "merge assets from wowza cloud" do
   it "should get asset data from service call" do
      res = Wowza::VodStreams.call
      expect(res["vod_streams"]).to be

      id = res["vod_streams"].first["id"]
      res = Wowza::VodStreamDetail.call(id)
      expect(res).to be
   end

   it "should get assets from controller" do
    get api_v1_cms_assets_path
    json = JSON.parse(response.body)
    expect(response).to be
    expect(json["vod_streams"].length).to be > 0

    id = json['vod_streams'].first["uid"]
    get api_v1_cms_asset_path(id: id)
    expect(response).to be

    json = JSON.parse(response.body)
    expect(json["vod_stream"]["uid"]).to eq(id)
   end

   xit "should save an asset" do
    rec = create( :cms_asset)
    get api_v1_cms_asset_path(id: rec.uid)
    expect(response).to be
    json = JSON.parse(response.body)
    expect(json["vod_stream"].id).to eq(rec.uid)
   end
  end
end

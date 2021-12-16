require 'rails_helper'

RSpec.describe "Api::V1::CmsAssets", type: :request do
  describe "GET LiveStreams" do
   it "should get live streams" do
      res = Wowza::LiveStreams.call
      expect(res["live_streams"]).to be
   end

  end
end

require 'rest-client'
module Wowza
  class VodStreams < WowzaBase

    def  call
      response = RestClient::Request.new(
        method: :get,
        url: url_base('vod_streams'),
        headers: header_data
        #payload: sso_payload.to_json
      ).execute

      #map_to_asset_list JSON.parse(response.body)
      JSON.parse(response.body)
    rescue => err
      raise StandardError, err.response.body
    end
  end
end

#------
# "vod_streams"=>[
#  {"id"=>"z32dc2jv",
#    "name"=>"Test Stream 4 on Dec 15, 2021 @ 02:12pm CST",
#    "created_at"=>"2021-12-15T20:12:23.000Z",
#    "updated_at"=>"2021-12-15T20:15:06.000Z"},... ],
# "pagination"=>{"payload_version"=>1.0, "total_records"=>4, "page"=>1,
#     "per_page"=>1000, "total_pages"=>1, "page_first_index"=>0, "page_last_index"=>3}}
#---
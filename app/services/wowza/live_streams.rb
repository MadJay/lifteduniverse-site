require 'rest-client'
module Wowza
  class LiveStreams < WowzaBase

    def  call
      response = RestClient::Request.new(
        method: :get,
        url: url_base('vod_streams'),
        headers: header_data
        #payload: sso_payload.to_json
      ).execute

      JSON.parse(response.body)
    rescue => err
      raise StandardError, err.response.body
    end
  end
end
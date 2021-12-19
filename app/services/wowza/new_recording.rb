require 'rest-client'
module Wowza
  class NewRecording < WowzaBase

    def initialize( uid, uploaded=false)
      @uid = uid
      @method = uploaded ? :put : :post
    end

    def  call
      response = RestClient::Request.new(
        method: @method,
        url: url_base('vod_streams'),
        headers: header_data
        #payload: sso_payload.to_json
      ).execute

      JSON.parse(response.body)
    rescue => err
      raise StandardError, err.response.body
    end

    private


  end
end

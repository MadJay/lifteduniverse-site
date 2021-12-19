require 'rest-client'
module Wowza
  class DeleteVodStreamDetail < WowzaBase

    def initialize(id)
      @id = id
    end

    def  call
      response = RestClient::Request.new(
        method: :delete,
        url: url_base("vod_streams/#{@id}"),
        headers: header_data
        #payload: sso_payload.to_json
      ).execute

      JSON.parse(response.body)
    rescue => err
      raise StandardError, err.response.body
    end
  end
end
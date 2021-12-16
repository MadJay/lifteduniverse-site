require 'rest-client'
module Wowza
  class LiveStreams < WowzaBase

    def  call
      response = RestClient::Request.new(
        method: :get,
        url: url_base('live_streams'),
        headers: header_data
        #payload: sso_payload.to_json
      ).execute

      puts JSON.parse(response.body)
      puts response.code
      # loop through response headers:
      #  response.each_header do |key, value|
      #    puts "#{key} => #{value}"
      #  end
        response
    end
  end
end
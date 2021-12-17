require 'rest-client'
module Wowza
  class WowzaBase < ApplicationService

    #TODO move these to credentials
    API_KEY = "8Uj2S4cNopi5QPdr5IZYvZhTTE0b8kF49FsmVMZaYPNKJHvmaq3UD1CKEHJt3152"
    API_ACCESS_KEY = "j3tZDR8oTLbZXtLoavnYmCFNLJFyq8zwLo6fx1rArgdSFn6KvPPGOyTV75RC3454"

    def header_data
      { content_type: :json,
        "wsc-api-key" => API_KEY,
        "wsc-access-key" => API_ACCESS_KEY
       }
    end

    def url_base(resource)
      "https://api.cloud.wowza.com/api/v1.7/#{resource}"
      #"https://api.docs.cloud.wowza.com/current/tag/vod_streams"
    end

  end
end
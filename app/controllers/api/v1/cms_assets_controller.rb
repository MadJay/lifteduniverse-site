module Api
  class V1::CmsAssetsController < Api::ApiController

    def index
      resp = Wowza::LiveStreams.call
      list = resp['live_streams']
      page = resp['pagination']
      #success_response serialized_object CmsAssetSerializer, serializer: CmsAssetSerializer
      success_response({live_streams: list})
      #render json: { live_streams: list}
    end

    def show
      resp = Wowza::LiveStreamDetail.call(params[:id])
      puts "#{resp}"
      success_response({live_stream: resp})
    end

    private

      def resource_params
        params.permit(:id)
      end
  end
end

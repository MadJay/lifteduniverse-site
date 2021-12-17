module Api
  class V1::CmsAssetsController < Api::ApiController

    def index
      resp = Wowza::LiveStreams.call
      list = resp['vod_streams']
      page = resp['pagination']
      #success_response serialized_object CmsAssetSerializer, serializer: CmsAssetSerializer
      #puts "#{resp}"
      success_response(resp)
      #render json: { live_streams: list}
    end

    def show
      resp = Wowza::LiveStreamDetail.call(params[:id])
      success_response(resp)
    end

    private

      def resource_params
        params.permit(:id)
      end
  end
end

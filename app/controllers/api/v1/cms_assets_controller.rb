  class Api::V1::CmsAssetsController < Api::ApiController

    def index
      vod_streams = Wowza::VodStreams.call
      create_new_assets(vod_streams["vod_streams"] )
      cms_list = CmsAsset.all.map{ |el|
        { uid: el.uid, title:el.title, created_at:el.created_at}
      }
      #page = resp['pagination']
      #success_response serialized_object CmsAssetSerializer, serializer: CmsAssetSerializer
      success_response( {vod_streams: cms_list})
    end

    def show
      resp = CmsAsset.find_by_uid(params[:id])
      if resp.nil?
        resp = Wowza::VodStreamDetail.call(params[:id])
      end

      if resp.nil?
        error_response("VOD Stream not found")
      else
        success_response({vod_stream: resp})
      end
    end

    def create
    end

    def update
    end

    def delete
      asset = CmsAsset.find_by_uid(params[:id])
      Wowza::DeleteVodStreamDetail.call(asset.vod_streams_uid)
      asset.archive
    end

    private

      def resource_params
        params.permit(:id)
      end

      def create_new_assets(list)
        list.each  do |vods|
          unless CmsAsset.where(vod_streams_uid: vods["id"]).exists?
            CmsAsset.create(vod_streams_uid: vods["id"], title: vods["name"],
              created_at: vods["created_at"])
          end
        end
      end
  end

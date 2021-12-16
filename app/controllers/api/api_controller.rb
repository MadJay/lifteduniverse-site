module Api
  class ApiController < ActionController::API

    #include ::Concerns::Responses
    def success_response data = nil, options = {}
      status = options[:status] || :ok
    json = {
        success: true,
        meta: options[:meta] || {},
        errors: {}
      }
      json.merge!(data) unless data.nil?
      render json: json, include: options[:include], status: status and return
    end

    def success_message options = {}
      status = options[:status] || :ok
      json = {
        success: true,
        data: nil,
        meta: {},
        errors: {}
      }
      json.merge!(summary: options[:summary]) if options[:summary]
      render json: json, include: options[:include], status: status and return
    end

    def paginated_response paginated, options = {}
      status = options[:status] || :ok
      data = build_serializer_array paginated, each_serializer: options[:serializer]

      json = {
        success: true,
        data: data,
        meta: pagination_info(paginated),
        errors: {}
      }

      json.merge!(summary: options[:summary]) if options[:summary]
      render json: json, include: options[:include], status: status and return
    end

    def error_response errors, options = {}
      status = options[:status] || :unprocessable_entity

      resp_errors = if errors.respond_to? :full_messages
        errors.full_messages
      else
        errors
      end

      json = {
        success: false,
        data: options[:data],
        errors: resp_errors,
      }
      render json: json, status: status and return
    end

    def serialized_object obj, options = {}
      klass = options.delete :serializer
      klass.new(obj, options)
    end

    def build_serializer_array data, options = {}
      serializer = options[:each_serializer] || find_serializer_for_response
      options.delete(:each_serializer)
      options[:scope] = api_user
      data.map { |d| serializer.new d, options }
    end

    def build_object_serializer_array data, options = {}
      serializer = options[:each_serializer] || find_serializer_for_response
      options.delete(:each_serializer)
      options[:scope] = api_user
      data.map do |d|
        {
          object_type: d.class.to_s,
          object: serializer.new(d, options)
        }
      end
    end

    def forbidden_request! code = 403
      error_response({}, status: code)
    end

    def find_serializer_for_response
      string = controller_path.classify + "Serializer"
      string.constantize
    end

    def page
      params[:page] ? params[:page] : 1
    end

    def first_page?
      page.to_i < 2
    end

    def pagination_info paginated
      {
        total_pages: paginated.total_pages,
        total_count: paginated.total_count,
        per_page: paginated.limit_value,
        current_page: paginated.current_page,
        next_page: paginated.next_page,
        prev_page: paginated.prev_page
      }
    end
  end
end

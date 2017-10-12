module BlacklightOaiProvider
  class SolrDocumentWrapper < ::OAI::Provider::Model
    attr_reader :model, :timestamp_field
    attr_accessor :options
    def initialize(controller, options = {})
      defaults = {
        timestamp: 'timestamp',
        limit: 15,
        set_class: 'BlacklightOaiProvider::Set'
      }

      @options = defaults.merge options
      @controller = controller

      @set = @options[:set_class].constantize
      @set.repository = @controller.repository if @set.respond_to?(:repository=)
      @set.search_builder = @controller.search_builder if @set.respond_to?(:search_builder=)
      @set.fields = @options[:set_fields] if @set.respond_to?(:fields=)

      @limit = @options[:limit].to_i
      @timestamp_field = @options[:timestamp_method] || @options[:timestamp]
      @timestamp_query_field = @options[:timestamp_field] || @options[:timestamp]
    end

    def sets
      @set.all
    end

    def earliest
      search_repository(fl: @timestamp_query_field, rows: 1).documents.first.send(@timestamp_field)
    rescue
      Time.at(0).utc
    end

    def latest
      search_repository(fl: @timestamp_query_field, sort: 'desc', rows: 1).documents.first.send(@timestamp_field)
    rescue
      Time.now.utc
    end

    def find(selector, options = {})
      return next_set(options[:resumption_token]) if options[:resumption_token]

      if :all == selector
        options[:until] = options[:until] + 1.second unless options[:until].nil?
        response = search_repository conditions: options
        if @limit && response.total > @limit
          return select_partial(OAI::Provider::ResumptionToken.new(options.merge(last: 0)), response.documents)
        end
        response.documents
      else
        begin
          response = @controller.fetch(selector).first
          response.documents.first
        rescue Blacklight::Exceptions::RecordNotFound
          nil
        end
      end
    end

    def select_partial(token, records)
      raise ::OAI::ResumptionTokenException unless records
      OAI::Provider::PartialResult.new(records, token.next(token.last + @limit))
    end

    def next_set(token_string)
      raise ::OAI::ResumptionTokenException unless @limit

      token = OAI::Provider::ResumptionToken.parse(token_string)
      response = search_repository(start: token.last, conditions: token.to_conditions_hash)

      if response.last_page?
        token = BlacklightOaiProvider::EmptyResumptionToken.new(last: token.last)
      end

      select_partial(token, response.documents)
    end

    private

    def search_repository(params = {})
      conditions = params.delete(:conditions) || {}

      params[:sort] = "#{@timestamp_query_field} #{params[:sort] || 'asc'}"
      params[:rows] = params[:rows] || @limit

      query = @controller.search_builder.with(@controller.params).merge(params).query

      query.append_filter_query(date_filter(conditions)) if conditions[:from] || conditions[:until]
      query.append_filter_query(@set.from_spec(conditions[:set])) if conditions[:set]

      @controller.repository.search query
    end

    def date_filter(conditions = {})
      from = conditions[:from] || earliest
      if conditions[:until]
        "#{@timestamp_query_field}:[#{from.utc.iso8601} TO #{conditions[:until].utc.iso8601}]"
      else
        "#{@timestamp_query_field}:[#{from.utc.iso8601} TO #{latest.utc.iso8601}+1SECOND]"
      end
    end
  end
end

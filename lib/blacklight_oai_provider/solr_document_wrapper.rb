module BlacklightOaiProvider
  class SolrDocumentWrapper < ::OAI::Provider::Model
    attr_reader :model, :timestamp_field
    attr_accessor :options
    def initialize(controller, options = {})
      @controller = controller

      defaults = { timestamp: 'timestamp', limit: 15 }
      @options = defaults.merge options

      @limit = @options[:limit]
      @doument_model = @controller.blacklight_config.document_model || ::SolrDocument
      @timestamp_field = @options[:timestamp_method] || @options[:timestamp]
      @timestamp_query_field = @options[:timestamp_field] || @doument_model.timestamp_field
    end

    def sets; end

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
        response = search_repository
        if @limit && response.total > @limit
          return select_partial(OAI::Provider::ResumptionToken.new(options.merge(last: 0)))
        end
        response.documents
      else
        response = @controller.fetch(selector.split('/', 2).last).first
        response.documents.first
      end
    end

    def select_partial(token)
      records = search_repository(start: token.last).documents

      raise ::OAI::ResumptionTokenException unless records

      OAI::Provider::PartialResult.new(records, token.next(token.last + @limit))
    end

    def next_set(token_string)
      raise ::OAI::ResumptionTokenException unless @limit

      token = OAI::Provider::ResumptionToken.parse(token_string)
      select_partial(token)
    end

    private

    def search_repository(params = {})
      params[:sort] = "#{@timestamp_query_field} #{params[:sort] || 'asc'}"
      params[:rows] = params[:limit] || @limit
      @controller.repository.search @controller.search_builder.with(@controller.params).merge(params)
    end
  end
end

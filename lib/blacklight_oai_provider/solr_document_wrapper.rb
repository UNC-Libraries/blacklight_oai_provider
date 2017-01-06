module BlacklightOaiProvider
  class SolrDocumentWrapper < ::OAI::Provider::Model
    attr_reader :model, :timestamp_field
    attr_accessor :options
    def initialize(controller, options = {})
      defaults = {
        timestamp: 'timestamp',
        limit: 15,
        sets: -> { sets_not_supported },
        set_query: ->(_spec) { sets_not_supported }
      }

      @options = defaults.merge options
      @controller = controller

      @limit = @options[:limit].to_i
      @timestamp_field = @options[:timestamp_method] || @options[:timestamp]
      @timestamp_query_field = @options[:timestamp_field] || @options[:timestamp]
    end

    def sets
      @options[:sets].call
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
        response = search_repository conditions: options
        if @limit && response.total > @limit
          return select_partial(OAI::Provider::ResumptionToken.new(options.merge(last: 0)), response.documents)
        end
        response.documents
      else
        response = @controller.fetch(selector.split('/', 2).last).first
        response.documents.first
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
      query.append_filter_query(@options[:set_query].call(conditions[:set])) if conditions[:set]

      @controller.repository.search query
    end

    def sets_not_supported
      raise ::OAI::SetException
    end

    def date_filter(conditions = {})
      from = conditions[:from] || earliest
      to = conditions[:until] || latest
      "#{@timestamp_query_field}:[#{from.utc.iso8601} TO #{to.utc.iso8601}]"
    end
  end
end

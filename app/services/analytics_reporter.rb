class AnalyticsReporter

  def self.report_to_ga(args)
    new(args).report_to_ga
  end

  def initialize(args)
    @ga_params = args[:ga_params] || {}
    @http_client = args[:http_client] || RestClient
  end

  def report_to_ga
    response = http_client.post('https://google-analytics.com/debug/collect', ga_params)
    filtered_ga_params = ga_params.dup
    filtered_ga_params[:tid] = '[FILTERED]'
    Rails.logger.info "GA responded to #{filtered_ga_params} with #{response.code} #{response.body}"
  end

  private

  attr_reader :ga_params, :http_client
end
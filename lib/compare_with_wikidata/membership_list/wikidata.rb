require 'rest-client'

module CompareWithWikidata
  module MembershipList
    class Wikidata
      WIKIDATA_SPARQL_URL = 'https://query.wikidata.org/sparql'.freeze

      attr_reader :sparql_query

      def initialize(sparql_query:)
        @sparql_query = sparql_query
      end

      def to_a
        @to_a ||= CSV.parse(sparql_response.to_s, headers: true, header_converters: :symbol, converters: nil).map(&:to_h)
      end

      private

      def sparql_response
        @sparql_response ||= RestClient.get WIKIDATA_SPARQL_URL, params: { query: sparql_query }, accept: 'text/csv'
      rescue RestClient::BadRequest
        raise "Bad Wikidata SPARQL request: most likely the query #{sparql_query.inspect} was invalid"
      rescue RestClient::Exception => e
        raise "The Wikidata SPARQL query #{sparql_query.inspect} failed with the following error: #{e.message}"
      end
    end
  end
end

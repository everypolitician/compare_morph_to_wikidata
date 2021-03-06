require 'compare_with_wikidata/diff_row'

require 'daff'
require 'csv'

module CompareWithWikidata
  class Comparison
    def initialize(sparql_items:, csv_items:, columns:)
      @sparql_items = sparql_items
      @csv_items = csv_items
      @columns = columns
    end

    def headers
      daff_results.first
    end

    def diff_rows
      @diff_rows ||= rows.map { |row| DiffRow.new(headers: headers, row: row) }
    end

    def to_csv
      CSV.generate do |csv|
        csv << headers
        rows.each { |row| csv << row }
      end
    end

    private

    attr_reader :sparql_items, :csv_items, :columns

    def daff_sparql_items
      [columns, *sparql_items.map { |r| r.values_at(*columns).map { |c| cleaned_cell(c) } }]
    end

    def daff_csv_items
      [columns, *csv_items.map { |r| r.values_at(*columns) }]
    end

    def cleaned_cell(cell)
      cell.to_s.sub(%r{^http://www.wikidata.org/entity/(Q\d+)$}, '\\1')
    end

    def daff_results
      @daff_results ||= daff_diff(daff_sparql_items, daff_csv_items)
    end

    # Daff diff rows, excluding moved rows (:)
    def rows
      daff_results.drop(1).reject { |r| r.first == ':' }
    end

    def daff_diff(data1, data2)
      t1 = Daff::TableView.new(data1)
      t2 = Daff::TableView.new(data2)

      alignment = Daff::Coopy.compare_tables(t1, t2).align

      data_diff = []
      table_diff = Daff::TableView.new(data_diff)

      flags = Daff::CompareFlags.new
      # We don't want any context in the resulting diff
      flags.unchanged_context = 0
      flags.show_unchanged_columns = true
      highlighter = Daff::TableDiff.new(alignment, flags)
      highlighter.hilite(table_diff)

      data_diff
    end
  end
end

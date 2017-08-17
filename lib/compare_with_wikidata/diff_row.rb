require 'compare_with_wikidata/diff_row/cell'

module CompareWithWikidata
  class DiffRow
    TEMPLATE_NAME_MAPPING = {
      '+++' => '/row_added_template'.freeze,
      '---' => '/row_removed_template'.freeze,
      '->'  => '/row_modified_template'.freeze,
    }.freeze

    def initialize(headers:, row:)
      @headers = headers
      @row = row
    end

    def wikitext
      "{{#{template_name}|#{template_params}}}"
    end

    def addition?
      change_type == '+++'
    end

    def removal?
      change_type == '---'
    end

    def modification?
      change_type == '->'
    end

    private

    attr_reader :headers, :row

    def template_name
      TEMPLATE_NAME_MAPPING[change_type]
    end

    def row_as_hash
      headers.zip(row).to_h
    end

    def change_type
      row_as_hash['@@']
    end

    def cell_class
      if modification?
        CellModified
      elsif addition?
        CellAdded
      elsif removal?
        CellRemoved
      else
        raise "Unknown change type: #{change_type}"
      end
    end

    def template_params
      (change_type_cell + value_cells).map { |v| v.join('=') }.join('|')
    end

    def change_type_cell
      row_as_hash.take(1)
    end

    def value_cells
      row_as_hash.drop(1).flat_map do |k, v|
        # Expand Wikidata IDs to templates.
        value = v.to_s.gsub(/Q(\d+)/, '{{Q|\\1}}')
        cell_class.new(key: k, value: value).cell_values
      end
    end
  end
end

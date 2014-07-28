require 'csv'

module CsvPivot
  class PivotTable

    DEFAULT_OPTIONS = {
      :headers          => true,
      :sort             => false,
      :sort_on          => 0, 
      :total_column     => false,
      :total_row        => false,
      :output_file      => nil
    }

    def initialize(opts = {})
      @opts = DEFAULT_OPTIONS.merge(opts)
      @input_path    = @opts[:input_path]
      @pivot_rows    = @opts[:pivot_rows]
      @pivot_columns = @opts[:pivot_columns]
      @pivot_data    = @opts[:pivot_data]
      @sort          = @opts[:sort]
      @output_file   = @opts[:output_file]
      @headers       = @opts[:headers]
      @method        = @opts[:aggregate_method]

      p = Proc.new do |array|  # the default aggregation method: sum
        array.map(&:to_i).reduce(0, :+)
      end

      @method      ||= p

      create_data_store
      aggregate_data 
      map_columns_and_rows
      sort if @sort
      create_table

      output_csv if @output_file

    end

    def pivot
      @pivoted_table
    end

    def create_data_store
      @data_store = Hash.new
      CSV.foreach(@input_path, :headers => @headers) do |row|
        if @data_store.include? "#{row[@pivot_rows]}:#{row[@pivot_columns]}" then
          @data_store["#{row[@pivot_rows]}:#{row[@pivot_columns]}"][:data].push(row[@pivot_data])
        else
          @data_store.store("#{row[@pivot_rows]}:#{row[@pivot_columns]}",
                            {:row    => row[@pivot_rows],
                             :column => row[@pivot_columns],
                             :data   => [row[@pivot_data]]} )
        end
      end
    end

    def aggregate_data
      @data_store.each_value do |value|
        value[:data] = @method.call(value[:data])
      end
    end

    def map_columns_and_rows
      @column_map = Hash.new
      @row_map    = Hash.new
      col_i = row_i = 1
      @data_store.each_value do |value|
        if !@column_map.include? value[:column]
          @column_map.store(value[:column], col_i) 
          col_i += 1
        end
        if !@row_map.include? value[:row]
          @row_map.store(value[:row], row_i) 
          row_i += 1
        end
      end
    end

    def sort
      sorted_columns = @column_map.keys.sort
      sorted_rows    = @row_map.keys.sort
      sorted_columns.each_with_index do |column, index|
        @column_map[column] = index + 1
      end
      sorted_rows.each_with_index do |row, index|
        @row_map[row] = index + 1
      end
    end

    def create_table
      @pivoted_table = [[]]
      @column_map.each do |key, value|
        @pivoted_table[0][value] = key
      end
      @row_map.each do |key, value|
        @pivoted_table[value] = [key]
      end
      @data_store.each_value do |value|
        row    = @row_map[value[:row]]
        column = @column_map[value[:column]]
        @pivoted_table[row][column] = value[:data]
      end
      @pivoted_table[0][0] = @pivot_rows if @headers
      @pivoted_table
    end

    def output_csv
      CSV.open(@output_path, "w") do |csv|
        @pivoted_table.each do |row|
          csv << row
        end
      end
    end

  end # end class
end

=begin
input = {:input_path => "/Users/mark.knutson/Documents/csv_pivot/spec/fixtures/license_server_record_history_by_regkey.csv", 
                     :pivot_rows => "month",    # group by
                     :pivot_columns => "limited_licensed_seats", # new headers
                     :pivot_data => "registration_key",
                     :output_file => "/Users/mark.knutson/Documents/csv_pivot/spec/fixtures/license_server_record_history_by_regkey_pivoted.csv",
                     :sort => false}
CsvPivot::PivotTable.new(input)
=end



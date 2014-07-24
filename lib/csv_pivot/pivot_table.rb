require 'csv'
require 'set'

module CsvPivot
  class PivotTable

    DEFAULT_OPTIONS = {
      :headers      => true,
      :sort         => true,
      :sort_on      => 0,
      :aggregation  => "sum", #sum, average, standard deviation, count
      :total_column => false,
      :total_row    => false
    }

    def initialize(opts = {})
      @opts = DEFAULT_OPTIONS.merge(opts)
      @input_path    = @opts[:input_path]
      @pivot_rows    = @opts[:pivot_rows]
      @pivot_columns = @opts[:pivot_columns]
      @pivot_data    = @opts[:pivot_data]
      @sort          = @opts[:sort]

      @headers       = @opts[:headers]
      
      create_header_row_and_label_column

      create_data_hash
      populate_data_hash

      aggregate_data
    end

    def pivot
      create_table
    end

    def create_header_row_and_label_column
      @header_row   = Hash.new
      @label_column = Hash.new
      @header_row.store(@pivot_rows, 0)#header for label column
      i = j = 1  #This is so un-rubyish?
      CSV.foreach(@input_path, :headers => @headers) do |row|
        if !@header_row.include? row[@pivot_columns]  then
          @header_row.store( row[@pivot_columns], i )
          i += 1
        end
        if !@label_column.include? row[@pivot_rows]  then
          @label_column.store(row[@pivot_rows], j)
          j += 1
        end
      end
    end

    def create_data_hash
      @data_hash = Hash.new
      @label_column.each_key do |row|
        @header_row.each_key do |column|
          @data_hash.store("#{row} #{column}", {:row => row, :column => column, :data => Array.new})
        end
      end
    end

    def populate_data_hash
      CSV.foreach(@opts[:input_path], :headers => @opts[:headers]) do |row|
        @data_hash["#{row[@pivot_rows]} #{row[@pivot_columns]}"][:data].push(row[@pivot_data].to_f)
      end
    end

    def aggregate_data
      @data_hash.each do |key, value|
        puts "#{key}:  #{value.inspect}"
        value[:data] = value[:column] if value[:column] == @pivot_columns
        value[:data] = value[:column] if value[:column] == @pivot_rows
        value[:data] = value[:data].inject(0, :+) if value[:column] != @pivot_columns || value[:column] != @pivot_rows
      end
    end

    def create_table
      @pivoted_table = Array.new
      @pivoted_table.push(@header_row.keys)
      @label_column.each do |label, index|
        @pivoted_table[index] = [label]
      end
      @data_hash.each_value do |value|
        row = @label_column[value[:row]]
        column = @header_row[value[:column]]
        @pivoted_table[row][column] = value[:data] if column != @header_row[@pivot_rows]
      end
      @pivoted_table
    end

  end # end class
end
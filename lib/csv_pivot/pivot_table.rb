require 'csv'

module CsvPivot
  class PivotTable

    DEFAULT_OPTIONS = {
      :headers          => true,
      :sort             => false,
      :sort_on          => 0, 
      :column_total     => false,
      :row_total        => false
    }

    def initialize(opts = {})
      p = Proc.new do |array|  # the default aggregation method: sum
        array.map(&:to_i).reduce(0, :+)
      end
      @opts = DEFAULT_OPTIONS.merge(opts)
      @input_path    = @opts[:input_path]
      @input_array   = @opts[:input_data]
      @pivot_rows    = @opts[:pivot_rows]
      @pivot_columns = @opts[:pivot_columns]
      @pivot_data    = @opts[:pivot_data]
      @sort          = @opts[:sort]
      @headers       = @opts[:headers]
      @column_total  = @opts[:column_total]
      @row_total     = @opts[:row_total]
      @method        = @opts[:aggregate_method] || p
    end

    def pivot
      if @input_path
        data_store = create_data_store_from_csv
      else
        data_store = create_data_store
      end

      aggregate_data(data_store)

      column_map, row_map = map_columns_and_rows(data_store)
      sort(column_map, row_map) if @sort

      create_table(data_store, column_map, row_map)
    end

    def pivot_to_csv(output_file)
      pivot_table = pivot
      output_csv(pivot_table, output_file)
    end

    def create_data_store
      data_store = Hash.new
      if @headers
        rows = @input_array[0].index(@pivot_rows)   
        cols = @input_array[0].index(@pivot_columns) 
        data = @input_array[0].index(@pivot_data)  
      else
        rows = @pivot_rows
        cols = @pivot_columns
        data = @pivot_data
      end

      @input_array.each_with_index do |row, i|
        if (@headers && i == 0) then next end
        if data_store.include? "#{row[rows]}:#{row[cols]}" then
          data_store["#{row[rows]}:#{row[cols]}"][:data].push(row[data])
        else
          data_store.store("#{row[rows]}:#{row[cols]}",
                            {:row    => row[rows],
                             :column => row[cols],
                             :data   => [row[data]]} )
        end
      end
      data_store
    end

    def create_data_store_from_csv
      data_store = Hash.new
      CSV.foreach(@input_path, :headers => @headers) do |row|
        if data_store.include? "#{row[@pivot_rows]}:#{row[@pivot_columns]}" then
          data_store["#{row[@pivot_rows]}:#{row[@pivot_columns]}"][:data].push(row[@pivot_data])
        else
          data_store.store("#{row[@pivot_rows]}:#{row[@pivot_columns]}",
                            {:row    => row[@pivot_rows],
                             :column => row[@pivot_columns],
                             :data   => [row[@pivot_data]]} )
        end
      end
      data_store
    end

    def aggregate_data(data_store)
      data_store.each_value do |value|
        value[:data] = @method.call(value[:data])
      end
    end

    def map_columns_and_rows(data_store)
      column_map = Hash.new
      row_map    = Hash.new
      col_i = row_i = 1
      data_store.each_value do |value|
        if !column_map.include? value[:column]
          column_map.store(value[:column], col_i) 
          col_i += 1
        end
        if !row_map.include? value[:row]
          row_map.store(value[:row], row_i) 
          row_i += 1
        end
      end
      [column_map, row_map]
    end

    def sort(column_map, row_map)
      sorted_columns = column_map.keys.sort
      sorted_rows    = row_map.keys.sort
      sorted_columns.each_with_index do |column, index|
        column_map[column] = index + 1
      end
      sorted_rows.each_with_index do |row, index|
        row_map[row] = index + 1
      end
    end

    def create_table(data_store, column_map, row_map)
      pivoted_table = [[]]
      column_map.each do |key, value|
        pivoted_table[0][value] = key
      end
      row_map.each do |key, value|
        pivoted_table[value] = [key]
      end
      data_store.each_value do |value|
        row    = row_map[value[:row]]
        column = column_map[value[:column]]
        pivoted_table[row][column] = value[:data]
      end
      pivoted_table[0][0] = @pivot_rows if @headers
      add_column_total(pivoted_table)   if @column_total
      add_row_total(pivoted_table)      if @row_total
      pivoted_table
    end

    def output_csv(pivoted_table, output_file)
      CSV.open(output_file, "w") do |csv|
        pivoted_table.each do |row|
          csv << row
        end
      end
    end

    def add_column_total(table)
      i = table[0].length
      table[0][i] = "Total"
      table.each_with_index do |row, index|
        next if index == 0
        row[i] = row[1..i].map(&:to_f).reduce(0, :+)
      end
    end

    def add_row_total(table)
      i = table.length
      table[i] = ["Total"]
      table.each_with_index do |row, j|
        next if j == 0 || j == i
        row.each_with_index do |value, k|
          next if k == 0 
          if table[i][k] 
            table[i][k] += value.to_f
          else
            table[i][k] = value.to_f
          end
        end
      end
      puts table.inspect
    end

  end # end class
end




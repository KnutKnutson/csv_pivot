class ArrayHandler
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
end
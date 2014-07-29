require 'csv'

class CsvHandler
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
end
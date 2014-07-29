require 'csv'
require 'spec_helper'
require 'csv_pivot/pivot_table'

describe CsvPivot::PivotTable do 
  #it exists
  describe '#pivot' do
    context 'Sum With Headers from csv' do

      let(:input) { {:input_path => "spec/fixtures/testcsv.csv", 
                     :pivot_rows => "date",    # group by
                     :pivot_columns => "name", # new headers
                     :pivot_data => "baz"} }
      let(:output) { CsvPivot::PivotTable.new(input).pivot }
      let(:expected) { [ ["date","mark","bear"],
                         ["4/1/11",6],
                         ["5/15/14",6,12],
                         ["4/7/12",nil,18],
                         ["5/11/11",6,12] ] }

      it 'produces pivoted data' do
        expect(output).to eq expected
      end
    end

    context 'sum Without Headers from csv' do

      let(:input) { {:input_path => "spec/fixtures/testcsv_noheaders.csv",
                     :pivot_rows => 3,    # group by
                     :pivot_columns => 4, # new headers
                     :pivot_data => 2,
                     :headers => false} }
      let(:output) { CsvPivot::PivotTable.new(input).pivot }
      let(:expected) { [ [nil,"mark","bear"],
                         ["4/1/11",6],
                         ["5/15/14",6,12],
                         ["4/7/12",nil,18],
                         ["5/11/11",6,12] ] }

      it 'produces pivoted data' do
        expect(output).to eq expected
      end
    end

    context 'Sum With Headers and Sort from csv' do

      let(:input) { {:input_path => "spec/fixtures/testcsv.csv", 
                     :pivot_rows => "date",    # group by
                     :pivot_columns => "name", # new headers
                     :pivot_data => "baz",
                     :sort => true} }
      let(:output) { CsvPivot::PivotTable.new(input).pivot }
      let(:expected) { [ ["date","bear","mark"],
                         ["4/1/11",nil,6],
                         ["4/7/12",18],
                         ["5/11/11",12,6],
                         ["5/15/14",12,6] ] }

      it 'produces pivoted data' do
        expect(output).to eq expected
      end
    end

    context 'Sum With Headers from array' do
      data = [  ["foo", "bar", "baz", "date", "name"],
                [1, 2, 3, "4/1/11", "mark"],
                [4, 5, 6, "5/15/14", "mark"],
                [7, 8, 9, "4/7/12", "bear"],
                [10, 11, 12, "5/11/11", "bear"],
                [1, 2, 3, "4/1/11", "mark"],
                [4, 5, 6, "5/11/11", "mark"],
                [7, 8, 9, "4/7/12", "bear"],
                [10, 11, 12, "5/15/14", "bear"] ]

      let(:input) { {:input_data => data, 
                     :pivot_rows => "date",    # group by
                     :pivot_columns => "name", # new headers
                     :pivot_data => "baz"} }
      let(:output) { CsvPivot::PivotTable.new(input).pivot }
      let(:expected) { [ ["date","mark","bear"],
                         ["4/1/11",6],
                         ["5/15/14",6,12],
                         ["4/7/12",nil,18],
                         ["5/11/11",6,12] ] }

      it 'produces pivoted data' do
        expect(output).to eq expected
      end
    end

    context 'Sum With No Headers from array and sort' do
      data = [  [1, 2, 3, "4/1/11", "mark"],
                [4, 5, 6, "5/15/14", "mark"],
                [7, 8, 9, "4/7/12", "bear"],
                [10, 11, 12, "5/11/11", "bear"],
                [1, 2, 3, "4/1/11", "mark"],
                [4, 5, 6, "5/11/11", "mark"],
                [7, 8, 9, "4/7/12", "bear"],
                [10, 11, 12, "5/15/14", "bear"] ]

      let(:input) { {:input_data => data, 
                     :pivot_rows => 3,    # group by
                     :pivot_columns => 4, # new headers
                     :pivot_data => 2,
                     :headers => false,
                     :sort => true} }
      let(:output) { CsvPivot::PivotTable.new(input).pivot }
      let(:expected) { [ [nil,"bear","mark"],
                         ["4/1/11",nil,6],
                         ["4/7/12",18],
                         ["5/11/11",12,6],
                         ["5/15/14",12,6] ] }

      it 'produces pivoted data' do
        expect(output).to eq expected
      end
    end

    context 'Sum With Headers from csv to csv' do
      output_path = "spec/fixtures/testcsv_pivoted.csv"

      let(:input) { {:input_path => "spec/fixtures/testcsv.csv", 
                     :pivot_rows => "date",    # group by
                     :pivot_columns => "name", # new headers
                     :pivot_data => "baz"} }
      let(:output) { `rm -f #{output_path}`
                    CsvPivot::PivotTable.new(input).pivot_to_csv(output_path)
                    File.exists? output_path }
      let(:expected) { true }

      it 'produces a csv file' do
        expect(output).to eq expected
      end

      let(:output) {  retrieved_data = Array.new
                      CSV.foreach(output_path, :headers => true) do |row|
                        retrieved_data << row
                      end
                      retrieved_data }
      let(:expected) { [ ["date","mark","bear"],
                         ["4/1/11",6],
                         ["5/15/14",6,12],
                         ["4/7/12",nil,18],
                         ["5/11/11",6,12] ] }

      it 'produced csv file is pivoted' do
        expect(output).to eq expected
      end 
    end

    #TEST DIFFERENT AGGREGATION METHODS
    context 'Average With Headers from csv' do
      p = Proc.new do |array|  
        array.map(&:to_i).reduce(0, :+)/array.length
      end
      let(:input) { {:input_path => "spec/fixtures/testcsv.csv", 
                     :pivot_rows => "date",    # group by
                     :pivot_columns => "name", # new headers
                     :pivot_data => "baz",
                     :aggregate_method => p} }
      let(:output) { CsvPivot::PivotTable.new(input).pivot }
      let(:expected) { [ ["date","mark","bear"],
                         ["4/1/11",3],
                         ["5/15/14",6,12],
                         ["4/7/12",nil,9],
                         ["5/11/11",6,12] ] }

      it 'produces pivoted data' do
        expect(output).to eq expected
      end
    end

    context 'Count With Headers from csv' do
      p = Proc.new do |array|  
        array.length
      end
      let(:input) { {:input_path => "spec/fixtures/testcsv.csv", 
                     :pivot_rows => "date",    # group by
                     :pivot_columns => "name", # new headers
                     :pivot_data => "baz",
                     :aggregate_method => p} }
      let(:output) { CsvPivot::PivotTable.new(input).pivot }
      let(:expected) { [ ["date","mark","bear"],
                         ["4/1/11",2],
                         ["5/15/14",1,1],
                         ["4/7/12",nil,2],
                         ["5/11/11",1,1] ] }

      it 'produces pivoted data' do
        expect(output).to eq expected
      end
    end

  end # end describe '#pivot'

end # end describe CsvPivot::PivotTable

=begin
[  [foo,bar,baz,date,name],
   [1,2,3,"4/1/11",mark],
   [4,5,6,"5/15/14",mark],
   [7,8,9,"4/7/12",bear],
   [10,11,12,"5/11/11",bear],
   [1,2,3,"4/1/11",mark],
   [4,5,6,"5/11/11",mark],
   [7,8,9,"4/7/12",bear],
   [10,11,12,"5/15/14",bear] ]
=end

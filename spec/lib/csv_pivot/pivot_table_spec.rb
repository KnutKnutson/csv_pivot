require 'spec_helper'
require 'csv_pivot/pivot_table'

describe CsvPivot::PivotTable do 
  #it exists
  describe '#pivot' do
    context 'Sum With Headers' do

      let(:input) { {:input_path => "/Users/mark.knutson/Documents/csv_pivot/spec/fixtures/testcsv.csv", 
                     :pivot_rows => "date",    # group by
                     :pivot_columns => "name", # new headers
                     :pivot_data => "baz"} }
      let(:output) { CsvPivot::PivotTable.new(input).pivot }
      let(:expected) { [ ["date","mark","bear"],
                         ["4/1/11",6,0],
                         ["5/15/14",6,12],
                         ["4/7/12",0,18],
                         ["5/11/11",6,12] ] }

      it 'produces pivoted data' do
        expect(output).to eq expected
      end
    end

    context 'Without Headers' do

      let(:input) { {:input_path => "/Users/mark.knutson/Documents/csv_pivot/spec/fixtures/testcsv_noheaders.csv",
                     :pivot_rows => 3,    # group by
                     :pivot_columns => 4, # new headers
                     :pivot_data => 2,
                     :headers => false} }
      let(:output) { CsvPivot::PivotTable.new(input).pivot }
      let(:expected) { [ [nil,"mark","bear"],
                         ["4/1/11",6,0],
                         ["5/15/14",6,12],
                         ["4/7/12",0,18],
                         ["5/11/11",6,12] ] }

      it 'produces pivoted data' do
        expect(output).to eq expected
      end
    end

    context 'Sum With Headers and Sort' do

      let(:input) { {:input_path => "/Users/mark.knutson/Documents/csv_pivot/spec/fixtures/testcsv.csv", 
                     :pivot_rows => "date",    # group by
                     :pivot_columns => "name", # new headers
                     :pivot_data => "baz",
                     :sort => true} }
      let(:output) { CsvPivot::PivotTable.new(input).pivot }
      let(:expected) { [ ["date","bear","mark"],
                         ["4/1/11",0,6],
                         ["5/11/11",12,6],
                         ["4/7/12",18,0],
                         ["5/15/14",12,6] ] }

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

# CsvPivot

TODO: Write a better gem description (and actually turn into a gem)

Takes a file path to a csv file, a column(s) and row(s) to pivot on.
Pivots
Returns an array of arrays.

## Installation

Add this line to your application's Gemfile:

    gem 'csv_pivot'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install csv_pivot

## Usage

TODO: Write more usage instructions here

require 'csv_pivot/pivot_table'

Takes a hash of options.  
The following are the args that must be specified:
input = {
  :input_path    => "spec/fixtures/testcsv.csv", 
  :pivot_rows    => "date",    # group by
  :pivot_columns => "name",    # new headers
  :pivot_data    => "baz" 
  }

call with:
array_of_arrays = CsvPivot::PivotTable.new(input).pivot

assuming you have a csv that looks something like this:   

foo, bar, baz, date,       name
1,   2,   3,   4/1/11,     mark
4,   5,   6,   5/15/14,    mark
7,   8,   9,   4/7/12,     bear
10,  11,  12,  5/11/11,    bear
1,   2,   3,   4/1/11,     mark
4,   5,   6,   5/11/11,    mark
7,   8,   9,   4/7/12,     bear
10,  11,  12,  5/15/14,    bear

The output of the call is:
[["date", "mark", "bear"], ["4/1/11", 6], ["5/15/14", 6, 12], ["4/7/12", nil, 18], ["5/11/11", 6, 12]]

which if printed to a csv row by row would be equivalent to:
"date",    "mark", "bear"
"4/1/11",   6
"5/15/14",  6,      12
"4/7/12",   nil,    18
"5/11/11",  6,      12

note that nils are returned in the absence of data and not zeroes.


Other optional args include:
:sort    => boolean
:headers => boolean
:aggregate_method => Proc # a proc that takes an array of values and returns desired output (e.g. average, max, min, sum, count, etc...)

The default aggregation method is sum.
The proc looks like:
p = Proc.new do |array|  
      array.map(&:to_i).reduce(0, :+)
    end

note that for user defined procs, the data to be aggregated is a string, and must be cast to numeric for mathematical aggregation.


## Contributing

1. Fork it ( https://github.com/[my-github-username]/csv_pivot/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

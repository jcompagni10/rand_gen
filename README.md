# Multi-Thread Random Generator 

This code uses 5 threads to generate a stream of random integers with the following frequency:
* 1 - 50%
* 2 - 25%
* 3 - 15%
* 4 - 5%
* 5 - 5%

A seperate I/O thread reads these inputs from a queue and writes them to the disc. The writer utilizes a heap sort to ensure they are written in the order that they are generated 

## Running the Code
To use the generator run ``bundle`` and then run: 
```ruby
ruby lib/rand_gen.rb 
```
This will generate 5000 random numbers, save them to ``./output.txt``
and return the frequency results for the last 100. 

An Rspec test suite can be run with: 
```ruby
ruby lib/rand_gen.rb 
```
This performs 3 tests: 
* Checks that specificied number of values are generated. 
* tests that values are generated with the expected frequencies (it is possible that this test might fail on occasion, but is statistically unlikely).
* Tests that values are written to the disc in the order in which they are generated. 

All tests are performed with a sample size[] of 50,000

# ActiveFacts::Compositions

Fact-based schemas are always in highly normalised or *elementary* form.
Most other schemas are composite (object-oriented, relational, warehousing, analytical, messaging, APIs, etc).

A *Composition* is a representation of the two-way mapping between an elementary schema and the composite schemas.

This gem provides:
* an API for compositions,
* several compositors which create Compositions - O-O, Relational and Data Vault and
* some generators which emit various kinds of output (Ruby, SQL) etc, for composed schemas.

This gem builds on the Fact Modeling Metamodel and languages of ActiveFacts.

## Installation

```ruby
gem 'activefacts-compositions'
```

And then execute:

    $ schema_compositor --help

## Usage

    $ bin/schema_compositor --relational --sql spec/relational/CompanyDirectorEmployee.cql
    $ bin/schema_compositor --binary --ruby spec/relational/CompanyDirectorEmployee.cql

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine from local source code, run `rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cjheath/activefacts-compositions.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


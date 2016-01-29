# ActiveFacts::Compositions

Fact-based schemas are always in highly normalised or *elementary* form.
Most other schemas are composite (object-oriented, relational, warehousing, analytical, messaging, APIs, etc).
This gem provides the framework for *Compositions*, which are representations of the two-way mapping between an elementary schema and a composite schema.
As such, it supports any-to-any mappings between different composite forms.

It also provides automated generators for some types of composite schemas, especially relational and Data Vault schemas.

This gem works with the Fact Modeling tools as part of ActiveFacts.

## Installation

Install as part of activefacts, just "gem install" directly, or add this line to your application's Gemfile:

```ruby
gem 'activefacts-compositions'
```

And then execute:

    $ bundle

## Usage

This gem adds schema manipulation tools (mappers, composers, transformations) to the generator framework for *activefacts*.
Refer to the afgen command-line tool for help:

    $ afgen --help

A stand-alone relational generator program is provided, mostly for exploratory purposes; use tracing to see what it is doing, e.g.:

    $ TRACE=relational bin/schema_compositor --surrogate spec/relational/CompanyDirectorEmployee.cql

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cjheath/activefacts-compositions.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


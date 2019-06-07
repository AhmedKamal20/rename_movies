# RenameMovies

[![Gem Version](https://badge.fury.io/rb/rename_movies.svg)](http://badge.fury.io/rb/rename_movies)

a Script to rename movies folders in a helpful format

## Installation

  $ gem install rename_movies

## Usage

- Set `RENAME_MOVIES_OMDB_KEY` `RENAME_MOVIES_DIR` as ENV Variables.
- run `rename_movies` and wait.

## Example

- 2046 (2004) DVDRip GoGo
> [ 2004 ] 2046 [ DVDRip ] [ R ] [ 7.5 ]

- 12.Years.A.Slave.2013.720p.BRRip.x264.AAC-ViSiON
> [ 2013 ] 12 Years A Slave [ 720p ] [ BRRip ] [ R ] [ 8.1 ]

- Create `info.yml` file for each movie contain its info.
- Create Sub Folders for each Genre, Country, Year, Rating

## Development

- Clone the Repo.
- To install dependencies, run `bin/setup`.
- To run the tests, run `rake test`.
- You can also run `bin/console` for an interactive prompt that will allow you to experiment.
- To install this gem onto your local machine, run `bundle exec rake install`.
- To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AhmedKamal20/rename_movies.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

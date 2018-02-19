# Torrent Post Processor
## Description
A script to automate the process of renaming and moving files from one directory to another, including creation of a subdirectory for files that are episodic in nature. The particular use case this was designed for is preparing files for use with a [Plex](https://www.plex.tv/) media server.

## Usage
This simple script is designed to be used with [Deluge](http://deluge-torrent.org/). It may also function with another torrenting client that supports automatically running scripts after completion; however, they would need to function similary to Deluge by providing the torrent name as `ARGV[1]` and the download path as `ARGV[2]`.

After cloning this repository, enable the Execute plugin in Deluge and set the path to `torrent_post_processor.rb` as the command to be run in the 'Torrent Complete' event.

There are 3 options that can be set via environment variables:
1. `TORRENT_FILE_SEPARATOR` - the character used to separate the name of the torrent
    - Default is `'.'`
2. `TORRENT_JOIN_CHARACTER` - the character used to re-join the relevant portions of the name
    - Default is `' '`
3. `TORRENT_FINAL_LOCATION` - the absolute path of desired destination to move the file(s)
    - Default is the download path supplied by Deluge
## Running Specs

Navigate to the repository's directory and
```bash
$ bundle install
```
then
```bash
$ rspec
```
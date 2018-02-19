# Torrent Post Processor
## Description
A script to automate the process of renaming and moving files from one directory to another, including creation of a subdirectory for files that are episodic in nature. The particular use case this was designed for is preparing files for use with a [Plex](https://www.plex.tv/) media server.

## Usage
This simple script is designed to be used with [Deluge](http://deluge-torrent.org/), or any other torrenting client that supports automatically running scripts after completion.

After cloning this repository, enable the Execute plugin in Deluge and set the path to `torrent_post_processor.rb` as the command to be run in the 'Torrent Complete' event.

## Running Specs

Navigate to the repository's directory and
```bash
$ bundle install
```
then
```bash
$ rspec
```
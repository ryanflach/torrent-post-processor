#!/usr/bin/env ruby

require 'find'
require 'fileutils'

class TorrentPostProcessor
  def initialize(torrent_name, download_path)
    @filename_separator = ENV['TORRENT_FILE_SEPARATOR'] || '.'
    @torrent_name       = get_clean_name(torrent_name)
    @download_path      = download_path
    @join_character     = ENV['TORRENT_JOIN_CHAR'] || ' '
    @final_destination  = ENV['TORRENT_FINAL_LOCATION'] || download_path
  end

  def process_completed_download
    new_names_by_path = formatted_filenames_by_path(find_files)

    move_files(new_names_by_path)

    clean_up(new_names_by_path.keys)
  end

  private

  attr_reader :torrent_name,
              :download_path,
              :filename_separator,
              :join_character,
              :final_destination

  # NOTE: TV shows will have season and episode data (e.g., S01E01), while movie
  #       torrents will typically have the 4-digit year after the title.
  TV_MATCHER    = /\AS\d{2}E\d{2}\z/
  MOVIE_MATCHER = /\A\d{4}\z/

  def get_clean_name(name)
    parts = name.split(filename_separator)

    if parts.count > 1 && parts.last =~ /\A[a-z]{3,4}/
      take_all_but_last(parts).join(filename_separator)
    else
      name
    end
  end

  def formatted_filenames_by_path(filenames)
    filenames.each_with_object({}) do |filename, by_path|
      name, file_type = parse_filename(filename)
      by_path[filename] = "#{name}.#{file_type}"
    end
  end

  def find_files
    [].tap do |found|
      Find.find(download_path) do |file|
        basename = File.basename(file)

        if basename =~ /\A#{Regexp.quote(torrent_name)}/ && basename !~ /nfo\z/
          found << file
          break
        end
      end
    end
  end

  def move_files(names_by_path)
    names_by_path.each do |current_location, new_filename|
      subdir = ensure_directory(new_filename)

      FileUtils.mv(current_location, File.join(final_destination, "#{subdir}", new_filename))
    end
  end

  def clean_up(original_locations)
    original_locations.each do |original_path|
      leftover_directory = hanging_directory(original_path)

      FileUtils.remove_dir(leftover_directory) if leftover_directory
    end
  end

  def parse_filename(filename)
    parts          = File.basename(filename).split(filename_separator)
    file_type      = parts.pop
    formatted_name = format_name(parts)

    [formatted_name, file_type]
  end

  def format_name(parts)
    [].tap do |name|
      parts.each do |segment|
        if final_tv_element?(segment)
          name << segment
          break
        elsif last_was_final_movie_element?(segment)
          break
        else
          name << segment
        end
      end
    end.join(join_character)
  end

  def final_tv_element?(segment)
    segment =~ TV_MATCHER
  end

  def last_was_final_movie_element?(segment)
    segment =~ MOVIE_MATCHER
  end

  def take_all_but_last(arr)
    arr[0...-1]
  end

  def ensure_directory(new_filename)
    base_name = new_filename.split('.').first.split

    return unless tv_show?(base_name.pop)

    subdir_name = base_name.join(' ')

    subdir = File.join(final_destination, subdir_name)

    Dir.mkdir(subdir) unless Dir.exist?(subdir)

    subdir_name
  end

  def hanging_directory(original_path) # broken
    base_dir = take_all_but_last(original_path.split('/'))

    return base_dir.join('/') if hanging?(base_dir)
  end

  def hanging?(original_directory_parts)
    return if (original_directory_parts - download_path.split('/')).empty?

    File.directory?(original_directory_parts.join('/'))
  end

  alias_method :tv_show?, :final_tv_element?
end

if __FILE__ == $0 && ARGV[1] && ARGV[2]
  TorrentPostProcessor.new(ARGV[1], ARGV[2]).process_completed_download
end

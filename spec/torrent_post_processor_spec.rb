require 'spec_helper'
require_relative '../bin/torrent_post_processor'

describe TorrentPostProcessor do
  let(:download_path) { File.join(__dir__, 'fixtures') }

  def create_movie_fixtures(directory)
    unless Dir.exist?(directory)
      FileUtils.mkdir_p(directory)
      create_file(directory, 'sample.avi')
      create_file(directory, 'Test.Movie.2017.BRRip.XviD.AC3-EV0.avi')
      create_file(directory, 'TorrentInfo.txt')
      create_file(directory, 'Test.Movie.2017.BRRip.XviD.AC3-EV0.nfo')
    end
  end

  def create_tv_fixtures
    create_file(download_path, 'TV.Show.S01E01.other.info.mkv')
  end

  def create_file(directory, filename)
    File.open(File.join(directory, filename), 'w') {}
  end

  describe '#process_completed_download' do
    before(:each) do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV)
        .to receive(:[])
        .with('TORRENT_FINAL_LOCATION')
        .and_return(download_path)
    end

    context 'file in subdirectory' do
      before(:each) do
        create_movie_fixtures(File.join(download_path, 'Test Movie'))
      end

      let(:processor) do
        TorrentPostProcessor.new(
          'Test.Movie.2017.BRRip.XviD.AC3-EV0',
          download_path
        )
      end

      let(:moved_file) { File.join(download_path, 'Test Movie.avi') }

      after(:each) { File.delete(moved_file) }

      it 'moves/renames the desired file' do
        processor.process_completed_download

        result = File.exist?(moved_file)

        expect(result).to be(true)
      end

      it 'deletes the subdirectory and unmoved files' do
        processor.process_completed_download

        result = Dir.exist?(moved_file)

        expect(result).to be(false)
      end
    end

    context 'standalone tv file in main directory' do
      before(:each) { create_tv_fixtures }

      let(:processor) do
        TorrentPostProcessor.new(
          'TV.Show.S01E01.other.info.mkv[E30]',
          download_path
        )
      end

      after(:each) { FileUtils.remove_dir(File.join(download_path, 'TV Show')) }

      it 'moves/renames the file to a named subdirectory' do
        processor.process_completed_download

        result = File.exist?(
          File.join(download_path, 'TV Show', 'TV Show S01E01.mkv')
        )

        expect(result).to be(true)
      end
    end
  end
end

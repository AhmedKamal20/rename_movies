require "rename_movies/version"
require "rename_movies/omdb/client"
require "rename_movies/info_extractor"

require "yaml"
require "logger"
require "fileutils"

module RenameMovies
  OMDB_KEY = ENV["RENAME_MOVIES_OMDB_KEY"]
  MOVIES_DIR = ENV["RENAME_MOVIES_DIR"]
  VERBOSE = false

  @logger = Logger.new(STDOUT)
  @client = OMDB::Client.new do |config|
    config.api_key = OMDB_KEY
    config.logger = @logger
  end

  def self.extract_movie_data
    @data = InfoExtractor.extract(@data)
  end

  def self.get_movie_data
    @data = @client.search(@data)
  end

  def self.save_movie_info
    file_name = MOVIES_DIR + @data[:original_name] + "/info.yml"
    @logger.info(@data.to_yaml) if VERBOSE
    @logger.info("Saving :: #{file_name}")
    File.write(file_name, @data.to_yaml)
  end

  def self.rename_folder
    if @data[:new_name] && !@data[:new_name].empty?
      new_file_name = []
      new_file_name << "[ #{@data[:year] || @data[:omdb_year]} ]" if @data[:year] || @data[:omdb_year]
      new_file_name << @data[:new_name]
      new_file_name << "[ #{@data[:resolution]} ]"                if @data[:resolution]
      new_file_name << "[ #{@data[:storage_format]} ]"            if @data[:storage_format]
      new_file_name << "[ #{@data[:rating]} ]"                    if @data[:rating]
      new_file_name << "[ #{@data[:imdb_rating]} ]"               if @data[:imdb_rating]
      new_file_name = new_file_name.join(" ")
      @logger.info("Moving to :: All Movies/#{new_file_name}")
      all_dir = "#{MOVIES_DIR}All Movies/"
      FileUtils.mkdir_p(all_dir)
      FileUtils.mv(MOVIES_DIR + @data[:original_name], all_dir + new_file_name)
      if @data[:genre]
        @data[:genre].split(", ").each do |genre|
          genre_dir = "#{MOVIES_DIR}By Genre/#{genre}/"
          FileUtils.mkdir_p(genre_dir)
          FileUtils.symlink(all_dir + new_file_name, genre_dir + new_file_name)
        end
      end
      if @data[:country]
        @data[:country].split(", ").each do |country|
          country_dir = "#{MOVIES_DIR}By Country/#{country}/"
          FileUtils.mkdir_p(country_dir)
          FileUtils.symlink(all_dir + new_file_name, country_dir + new_file_name)
        end
      end
      if @data[:omdb_year]
        year_dir = "#{MOVIES_DIR}By Year/#{@data[:omdb_year]}/"
        FileUtils.mkdir_p(year_dir)
        FileUtils.symlink(all_dir + new_file_name, year_dir + new_file_name)
      end
      if @data[:rating]
        rating_dir = "#{MOVIES_DIR}By Rating/#{@data[:rating]}/"
        FileUtils.mkdir_p(rating_dir)
        FileUtils.symlink(all_dir + new_file_name, rating_dir + new_file_name)
      end
    end
  end

  default = ["All Movies", "By Genre", "By Country", "By Year", "By Rating"].map { |e| MOVIES_DIR + e }
  children = Dir.glob(MOVIES_DIR + "*") - default
  dirs = children.select { |f| File.directory? f }
  dc = dirs.count
  dirs.each_with_index do |foldername, i|
    @logger.info("Working on :: #{foldername}")
    next unless File.directory?(foldername)
    next if Dir.entries(foldername).include?("info.yml")
    @data = %i[original_name new_name omdb_title year omdb_year storage_format resolution encoding_standard
               audio_quality rating runtime country genre imdb_rating imdb_id imdb_url].product([nil]).to_h
    @data[:original_name] = foldername.sub(MOVIES_DIR, "")
    extract_movie_data
    get_movie_data if OMDB_KEY
    save_movie_info
    rename_folder
    printf("\r[%-25s] #{i + 1}/#{dc} ", "=" * ((i + 1.0) / dc * 25))
  end
  puts " Movies Renamed" unless dc.zero?
end

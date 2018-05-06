require "rename_movies/version"
require 'yaml'
require 'json'
require 'open-uri'
require 'logger'

module RenameMovies

  @logger = Logger.new(STDOUT)

  OMDB_KEY = ENV['RENAME_MOVIES_OMDB_KEY']
  MOVIES_DIR = ENV['RENAME_MOVIES_DIR']
  VERBOSE = false

  RESOLUTIONS = %w[1080p 720p 480p 560p 4k uhd hd hq]
  STORAGE_FORMATS = %w[bluray brrip bdrip dvdrip dvdscr web-dl webrip hdrip hdtv]
  ENCODING_STANDARDS = %w[h264 x264 xvid divx h\.264]
  AUDIO_QUALITIES = %w[ac3 aac dts dd5\.1 mp3 6ch 5\.1]
  R_SEPARATORS = ['\(', '\[', '\{', '\.', '\s']
  L_SEPARATORS = ['\)', '\]', '\}', '\.', '\s']
  CLEAN_KEYWORDS = %w[limited special extended uncensored director\ss\scut dircut repack redux uncut unrated boxset final\scut]

  YEAR_MATCHERS = [
    Regexp.new("[#{R_SEPARATORS.join('|')}](?<year>\\d{4})(?!\\w)[#{L_SEPARATORS.join('|')}]?"),
  ]
  VIDEO_QUALITY_MATCHERS = [
    Regexp.new("(?<encoding_standard>#{ENCODING_STANDARDS.join('|')})", 'i'),
    Regexp.new("(?<storage_format>#{STORAGE_FORMATS.join('|')})", 'i'),
    Regexp.new("(?<resolution>#{RESOLUTIONS.join('|')})", 'i'),
  ]
  AUDIO_QUALITY_MATCHERS = [
    Regexp.new("(?<audio_quality>#{AUDIO_QUALITIES.join('|')})", 'i'),
  ]
  CLEAN_NAME_MATCHERS = [
    Regexp.new("[#{R_SEPARATORS.join('|')}](\\d{4})(?!\\w)[#{L_SEPARATORS.join('|')}]?.*"),
    Regexp.new("(#{ENCODING_STANDARDS.join('|')}).*", 'i'),
    Regexp.new("(#{STORAGE_FORMATS.join('|')}).*", 'i'),
    Regexp.new("(#{RESOLUTIONS.join('|')}).*", 'i'),
    Regexp.new("\\s(#{CLEAN_KEYWORDS.join('|')}).*", 'i'),
  ]

  def self.extract_year
    YEAR_MATCHERS.each do |format_regex|
      match = format_regex.match(@data[:original_name])
      @data[:year] = match[:year] if match
    end
  end

  def self.extract_video_quality
    VIDEO_QUALITY_MATCHERS.each do |format_regex|
      match = format_regex.match(@data[:original_name])
      @data[:encoding_standard] = match[:encoding_standard] if match && (match[:encoding_standard] rescue nil)
      @data[:storage_format] = match[:storage_format] if match && (match[:storage_format] rescue nil)
      @data[:resolution] = match[:resolution] if match && (match[:resolution] rescue nil)
    end
  end

  def self.extract_audio_quality
    AUDIO_QUALITY_MATCHERS.each do |format_regex|
      match = format_regex.match(@data[:original_name])
      @data[:audio_quality] = match[:audio_quality] if match
    end
  end

  def self.extract_name
    @data[:new_name] = @data[:original_name]
    @data[:new_name] = @data[:new_name].gsub(/\W+/, ' ')
    CLEAN_NAME_MATCHERS.each do |format_regex|
      @data[:new_name] = @data[:new_name].sub(format_regex, '')
    end
    @data[:new_name] = @data[:new_name].split.join(" ")
  end

  def self.get_movie_data
    if @data[:new_name] && @data[:year]
      url = "http://www.omdbapi.com/?t=#{@data[:new_name]}&y=#{@data[:year]}&apikey=#{OMDB_KEY}"
    elsif @data[:new_name]
      url = "http://www.omdbapi.com/?t=#{@data[:new_name]}&apikey=#{OMDB_KEY}"
    else
      url = "http://www.omdbapi.com/?t=#{@data[:original_name]}&apikey=#{OMDB_KEY}"
    end
    @logger.info("Requesting :: #{url}")
    res = open(url).read
    res = JSON.parse(res)
    @data[:omdb_title] = res['Title']       unless res['Title'] == "N/A"
    @data[:omdb_year] = res['Year']         unless res['Year'] == "N/A"
    @data[:genre] = res['Genre']            unless res['Genre'] == "N/A"
    @data[:rating] = res['Rated']           unless res['Rated'] == "N/A"
    @data[:runtime] = res['Runtime']        unless res['Runtime'] == "N/A"
    @data[:country] = res['Country']        unless res['Country'] == "N/A"
    @data[:imdb_rating] = res['imdbRating'] unless res['imdbRating'] == "N/A"
    @data[:imdb_id] = res['imdbID']         unless res['imdbID'] == "N/A"
    @data[:imdb_url] = "https://www.imdb.com/title/#{@data[:imdb_id]}/" if @data[:imdb_id]
  end

  def self.save_movie_info
    file_name = MOVIES_DIR + @data[:original_name] + '/info.yml'
    @logger.info(@data.to_yaml) if VERBOSE
    @logger.info("Saving :: #{file_name}")
    File.write(file_name, @data.to_yaml)
  end

  def self.rename_folder
    if @data[:new_name] && !@data[:new_name].empty?
      new_file_name = []
      new_file_name << "[ #{@data[:year] || @data[:omdb_year]} ]" if @data[:year] || @data[:omdb_year]
      new_file_name << @data[:new_name]
      new_file_name << "[ #{@data[:resolution]} ]" if @data[:resolution]
      new_file_name << "[ #{@data[:storage_format]} ]" if @data[:storage_format]
      new_file_name << "[ #{@data[:rating]} ]" if @data[:rating]
      new_file_name << "[ #{@data[:imdb_rating]} ]" if @data[:imdb_rating]
      @logger.info("Renaming to :: #{new_file_name.join(' ')}")
      File.rename(MOVIES_DIR + @data[:original_name], MOVIES_DIR + new_file_name.join(' '))
    end
  end

  Dir.glob(MOVIES_DIR + '*').each do |foldername|
    @logger.info("Working on :: #{foldername}")
    next unless File.directory?(foldername)
    next if Dir.entries(foldername).include?("info.yml")
    @data = %i[original_name new_name omdb_title year omdb_year storage_format resolution encoding_standard
               audio_quality rating runtime country genre imdb_rating imdb_id imdb_url].product([nil]).to_h
    @data[:original_name] = foldername.sub(MOVIES_DIR, '')
    extract_year
    extract_video_quality
    extract_audio_quality
    extract_name
    get_movie_data if OMDB_KEY
    save_movie_info
    rename_folder
  end

end

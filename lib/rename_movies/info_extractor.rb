require "json"
require "open-uri"

module RenameMovies
  class InfoExtractor
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
      Regexp.new("(?<encoding_standard>#{ENCODING_STANDARDS.join('|')})", "i"),
      Regexp.new("(?<storage_format>#{STORAGE_FORMATS.join('|')})", "i"),
      Regexp.new("(?<resolution>#{RESOLUTIONS.join('|')})", "i"),
    ]
    AUDIO_QUALITY_MATCHERS = [
      Regexp.new("(?<audio_quality>#{AUDIO_QUALITIES.join('|')})", "i"),
    ]
    CLEAN_NAME_MATCHERS = [
      Regexp.new("[#{R_SEPARATORS.join('|')}](\\d{4})(?!\\w)[#{L_SEPARATORS.join('|')}]?.*"),
      Regexp.new("(#{ENCODING_STANDARDS.join('|')}).*", "i"),
      Regexp.new("(#{STORAGE_FORMATS.join('|')}).*", "i"),
      Regexp.new("(#{RESOLUTIONS.join('|')}).*", "i"),
      Regexp.new("\\s(#{CLEAN_KEYWORDS.join('|')}).*", "i"),
    ]

    def self.extract(movie_data)
      @movie_data = movie_data

      extract_year
      extract_video_quality
      extract_audio_quality
      extract_name

      @movie_data
    end

    private

      def self.extract_year
        YEAR_MATCHERS.each do |format_regex|
          match = format_regex.match(@movie_data[:original_name])
          @movie_data[:year] = match[:year] if match
        end
      end

      def self.extract_video_quality
        VIDEO_QUALITY_MATCHERS.each do |format_regex|
          match = format_regex.match(@movie_data[:original_name])
          @movie_data[:encoding_standard] = match[:encoding_standard] if match && (match[:encoding_standard] rescue nil)
          @movie_data[:storage_format] = match[:storage_format] if match && (match[:storage_format] rescue nil)
          @movie_data[:resolution] = match[:resolution] if match && (match[:resolution] rescue nil)
        end
      end

      def self.extract_audio_quality
        AUDIO_QUALITY_MATCHERS.each do |format_regex|
          match = format_regex.match(@movie_data[:original_name])
          @movie_data[:audio_quality] = match[:audio_quality] if match
        end
      end

      def self.extract_name
        @movie_data[:new_name] = @movie_data[:original_name]
        @movie_data[:new_name] = @movie_data[:new_name].gsub(/\W+/, " ")
        CLEAN_NAME_MATCHERS.each do |format_regex|
          @movie_data[:new_name] = @movie_data[:new_name].sub(format_regex, "")
        end
        @movie_data[:new_name] = @movie_data[:new_name].split.join(" ")
      end
  end
end

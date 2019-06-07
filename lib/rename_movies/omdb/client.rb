require "json"
require "open-uri"

module RenameMovies
  module OMDB
    class Client
      attr_accessor :api_key, :logger

      def initialize
        yield self
      end

      def search(movie_data)
        movie_name = movie_data[:new_name] ? movie_data[:new_name] : movie_data[:original_name]
        movie_year = movie_data[:year] ? movie_data[:year] : ""

        url = "http://www.omdbapi.com/?t=#{movie_name}&y=#{movie_year}&apikey=#{api_key}"

        logger.info("Requesting :: #{url}")

        res = open(url).read
        res = JSON.parse(res)

        unless res["Response"] == "False"
          movie_data[:omdb_title] = res["Title"]            unless res["Title"] == "N/A"
          movie_data[:omdb_year] = res["Year"]              unless res["Year"] == "N/A"
          movie_data[:genre] = res["Genre"]                 unless res["Genre"] == "N/A"
          movie_data[:rating] = res["Rated"]                unless res["Rated"] == "N/A"
          movie_data[:runtime] = res["Runtime"]             unless res["Runtime"] == "N/A"
          movie_data[:country] = res["Country"]             unless res["Country"] == "N/A"
          movie_data[:imdb_rating] = res["imdbRating"]      unless res["imdbRating"] == "N/A"
          movie_data[:imdb_id] = res["imdbID"]              unless res["imdbID"] == "N/A"
          movie_data[:imdb_url] = imdb_url(res["imdbID"])   unless res["imdbID"] == "N/A"
        end
        movie_data
      end

      private

        def imdb_url(imdb_id)
          "https://www.imdb.com/title/#{imdb_id}/"
        end
    end
  end
end

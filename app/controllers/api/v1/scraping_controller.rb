module Api
  module V1
    class ScrapingController < ApplicationController
      def scrape
        request_data = JSON.parse(request.body.read)
        
        scraper = WebsiteScraper.new
        scraped_data = scraper.scrape_data(request_data)

        render json: scraped_data
      end
    end
  end
end

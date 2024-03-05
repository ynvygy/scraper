# spec/controllers/api/v1/scraping_controller_spec.rb

require 'rails_helper'

RSpec.describe Api::V1::ScrapingController, type: :controller do
  describe 'POST #scrape' do
    let(:request_data) do
      {
        "url": "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
        "fields": { 
          "price": ".price-box__price",
          "rating_count": ".ratingCount", 
          "rating_value": ".ratingValue" 
        }
      }.to_json
    end

    let(:request_data_meta) do
      {
        url: 'https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm',
        fields: { 'meta' => ['keywords', 'twitter:image'] }
      }.to_json
    end

    it 'returns a successful response with mocked data' do
      allow(WebsiteScraper).to receive(:new).and_return(website_scraper_instance)
      allow(website_scraper_instance).to receive(:scrape_data).and_return(mocked_response)

      post :scrape, body: request_data

      expect(response).to have_http_status(:success)

      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to_not include('meta')
      expect(parsed_response).to include('rating_count') 
    end

    it 'returns a successful response with mocked meta data' do
      allow(WebsiteScraper).to receive(:new).and_return(website_scraper_instance)
      allow(website_scraper_instance).to receive(:scrape_data).and_return(mocked_meta_response)

      post :scrape, body: request_data

      expect(response).to have_http_status(:success)

      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to include('meta')

      meta_data = parsed_response['meta']
      expect(meta_data).to include('keywords', 'twitter:image')
    end

    private

    def website_scraper_instance
      @website_scraper_instance ||= instance_double(WebsiteScraper)
    end

    def mocked_meta_response
      {
        'meta' => {
          'keywords' => 'Mocked keywords',
          'twitter:image' => 'https://mocked.image.url'
        }
      }
    end

    def mocked_response
      {
        "price": "18290,-",
        "rating_value": "4,9",
        "rating_count": "7 hodnocení"
      }
    end
  end
end

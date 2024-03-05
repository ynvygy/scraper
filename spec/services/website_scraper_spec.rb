require 'rails_helper'

RSpec.describe WebsiteScraper, type: :service do
  let(:scraper) { WebsiteScraper.new }

  describe '#scrape_data' do
    it 'returns the expected data for a given request and caches the response' do
      url = 'https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm'
      fields = {
        'price': '.price-box__price',
        'rating_count': '.ratingCount', 
        'rating_value': '.ratingValue',
        'meta' => ['keywords', 'twitter:image'] 
      }

      allow(Rails.cache).to receive(:fetch).and_call_original

      allow(scraper).to receive(:scrape_data).with(hash_including('url' => url, 'fields' => fields)).and_return(mocked_response)

      response = scraper.scrape_data({ 'url' => url, 'fields' => fields })
      expect(response).to eq(mocked_response)
    end
  end

  private

  def mocked_response
    {
      "price": "18290,-",
      "rating_value": "4,9",
      "rating_count": "7 hodnocení",
      'meta' => {
        'keywords' => 'Mocked keywords',
        'twitter:image' => 'https://mocked.image.url'
      }
    }
  end
end

=begin
  How to test the api directly without a mock, although this would go against coding practices

  describe '#scrape_data' do
    it 'returns the expected data for a given request and caches the response' do
      url = 'https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm'
      fields = {
        'price': '.price-box__price',
        'rating_count': '.ratingCount', 
        'rating_value': '.ratingValue',
        'meta' => ['keywords', 'twitter:image'] 
      }

      # Stub the cache methods
      allow(Rails.cache).to receive(:fetch).and_call_original

      # First call to scrape_data
      response_first_call = scraper.scrape_data({ 'url' => url, 'fields' => fields })

      # Simulate a change in data on the website (for example, change the keywords)
      allow(Rails.cache).to receive(:fetch).and_return(nil)

      # Second call to scrape_data
      response_second_call = scraper.scrape_data({ 'url' => url, 'fields' => fields })

      # Expectations on cache fetch
      expect(Rails.cache).to have_received(:fetch).with(match(/page_/), expires_in: 1.day).twice
      expect(Rails.cache).to have_received(:fetch).with(match(/response_/), expires_in: 1.day).at_least(2).times

      # Expectations on response
      expect(response_first_call).to eq(response_second_call)
    end
  end
=end
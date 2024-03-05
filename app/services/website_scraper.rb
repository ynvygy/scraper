class WebsiteScraper
  def initialize
    @cache = Rails.cache
  end

  def scrape_data(request_data)
    url = request_data['url']
    fields = request_data['fields']

    cached_page = get_page_cache(url)
    
    #get_data_cache(cached_page, url, fields)
    parse_html(cached_page, url, fields)
  end

  private

  # initial version - saving cached data per fields request
  def get_data_cache(page, url, fields)
    response_cache_key = "response_#{url.parameterize}_#{fields.keys.join('_')}"
    @cache.fetch(response_cache_key, expires_in: 1.day) do
      parse_html(page, fields)
    end
  end

  def get_page_cache(url)
    page_cache_key = "page_#{url.parameterize}"
    @cache.fetch(page_cache_key, expires_in: 1.day) do
      scrape_with_browser(url)
    end
  end

  def scrape_with_browser(url)
    browser = Watir::Browser.new(:chrome)
    browser.goto(url)
    scraped_data = browser.html
    browser.close
    scraped_data
  end

  def parse_html(html, url, fields)
    parsed_data = {}
    doc = Nokogiri::HTML(html)

    fields.each do |key, selector|
      if key == 'meta'
        parsed_data['meta'] = extract_meta_content(doc, url, selector)
      else
        cache_key = "response_#{url.parameterize}_#{key}"
        parsed_data[key] = @cache.fetch(cache_key, expires_in: 1.day) do
          doc.css(selector).text
        end
      end
    end

    parsed_data
  end

  def extract_meta_content(doc, url, selectors)
    extracted_data = {}
    selectors.each do |selector|
      cache_key = "response_#{url.parameterize}_meta_#{selector}"
      extracted_data[selector] = @cache.fetch(cache_key, expires_in: 1.day) do
        doc.at("meta[name='#{selector}']")['content']
      end
    end
    extracted_data
  end
end

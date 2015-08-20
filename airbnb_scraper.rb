require 'open-uri'
require 'nokogiri'
require 'csv'

#store URL to be scraped
url = "https://www.airbnb.com/s/San-Francisco--CA--United-States"

# Parse the page with Nokogiri
page = Nokogiri::HTML(open(url))

# Scrape the max number of pages and store in max_page variable
page_numbers = []
page.css("div.pagination ul li a[target]").each do |line|
  page_numbers << line["target"]
end

max_page = page_numbers.max.to_i

#initialize empty array
name = []
price = []
description = []

# Loop once for every page of search results
max_page.times do |i|
  
  #store URL to be scraped
  url = "https://www.airbnb.com/s/San-Francisco--CA--United-States?page=#{i+1}"

  # Parse the page with Nokogiri
  page = Nokogiri::HTML(open(url))

  # Store data in arrays
 
  page.css('h3.h5.listing-name').each do |line|
    name << line.text.strip
  end

  
  page.css('span.h3.price-amount').each do |line|
    price << line.text
  end

  
  page.css('div.text-muted.listing-location.text-truncate').each do |line|
    subarray = line.text.strip.split(/ · /)
    
    if subarray.length == 3
      description << subarray
    else
      description << [subarray[0], "0 reviews", subarray[1]]
    end
  end
end

# Write data to CSV file
CSV.open("airbnb_listing.csv", "w") do |file|
  file << ['Listing name', 'Listing price', 'Room type', 'Reviews']
  name.length.times do |i|
    # airbnb site change the description field
    if description[i].length == 1
      file << [name[i], price[i], description[i][0], "N/A"]
    elsif description[i].length == 2
      file << [name[i], price[i], description[i][0], description[i][1]]
    else description[i].length == 3
      file << [name[i], price[i], description[i][0], description[i][1], description[i][2]]
    end
  end
end
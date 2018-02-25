require 'httparty'
require 'nokogiri'
require 'pry'

def scrape_page(type)
  field = type.to_s.downcase
  uri = 'https://www.nottingham.ac.uk/computerscience/people/'
  page = Nokogiri::HTML(HTTParty.get(uri))
  page.at_css("div#lookup-#{field}").css('tr').map do |row|
    if row.css('th').text.to_s.include?('Academic Staff in Malaysia')
      break
    end
    unless row.css('a')[0].nil?
      unless row.css('td')[0].css('a')[0]['href'].include? 'mailto:'
        names = row.css('td')[0].css('a')[0].text.to_s.split(', ')
        first_name = names[1].delete(' ')
        last_name = names[0].delete(' ')
        webpage = uri + row.css('td')[0].css('a')[0]['href']
        room = scrape_room webpage
        name = first_name + ' ' + last_name
        contact = row.css('td')[1].text
        title = row.css('td')[2].text
        email = row.css('a')[0]['href'] + '@nottingham.ac.uk'
        image_url = uri + 'staff-images/' + first_name.downcase + last_name.downcase + '.jpg'
        puts "{name:#{name}, room:#{room}, contact:#{contact}, title:#{title}, email:#{email}, image:#{image_url}}"
        # Face.create(:name => name, :room => room, :modules => "null", :email => email, :photo => image_url, :phone => contact, :position => title, :_type => type)
      end
    end
  end
end

def scrape_room(webpage)
  page = Nokogiri::HTML(HTTParty.get(webpage))
  address_line = page.at_css("div#lookup-personal-details").css('span.street-address').first.to_s
  temp = address_line.split(">")[1].to_s
  temp = temp.split("<")[0]
  if temp.to_s.include? '&amp;'
    temp.to_s.sub! '&amp;', '&'
  end
  if temp.to_s.length == 0
    temp = "null"
  end
  temp.strip
end

scrape_page("Administrative")
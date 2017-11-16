require 'httparty'
require 'nokogiri'
require 'pry'

def scrape(field, page)
  staff_array = []

  page.at_css("div#lookup-#{field}").css('tr').map do |row|
    if row.css('th').text.to_s.include?('Academic Staff in Malaysia')
      break
    end
    unless row.css('a')[0].nil?
      unless row.css('td')[0].css('a')[0]['href'].include? 'mailto:'
        names = row.css('td')[0].css('a')[0].text.to_s.split(', ')
        first_name = names[1]
        last_name = names[0]
        name = first_name + ' ' + last_name
        contact = row.css('td')[1].text
        title = row.css('td')[2].text
        email = row.css('a')[0]['href'] + '@nottingham.ac.uk'
        uri = 'https://www.nottingham.ac.uk/computerscience/people/'
        image_url = uri + 'staff-images/' + last_name.downcase + first_name.downcase + '.jpg'
        Face.create(:name => name, :room => "null", :modules => "null", :email => email, :photo => image_url, :phone => contact, :position => title, :_type => field)
      end
    end
  end
  # return staff array to application
  staff_array
end

uri = 'https://www.nottingham.ac.uk/computerscience/people/'
parse_page = Nokogiri::HTML(HTTParty.get(uri))
staff_list = scrape 'administrative', parse_page
staff_list << scrape('technical', parse_page)
staff_list << scrape('academic', parse_page)
puts staff_list
# puts staff_list.count

Pry.start(binding)
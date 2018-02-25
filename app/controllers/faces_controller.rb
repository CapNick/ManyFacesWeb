require 'httparty'
require 'nokogiri'
require 'spawnling'

class FacesController < ApplicationController

  include HTTParty
  include Nokogiri

  # call the get_face method at the beginning of these actions
  before_action :authenticate_user!
  before_action :get_face, only: [:edit, :update, :show, :destroy]

  def index
    @faces = Face.order('name').page(params[:page]).per(9)
    @faces_all = Face.all.where(visible: true)
  end

  def new
    @face = Face.new
  end

  def edit
  end

  def update
    if @face.update(face_params)
      flash[:notice] = "Staff member was successfully updated."
      redirect_to faces_path
    else
      # reload the /faces/edit page
      render 'edit'
    end
  end

  def create
    # render plain: params[:face].inspect
    @face = Face.new(face_params)
    if @face.save
      flash[:notice] = "Staff member was successfully created."
      redirect_to face_path(@face)
    else
      # reload the /faces/new page
      render 'new'
    end
  end

  def show
  end

  def destroy
    @face.destroy
    flash[:notice] = "Staff member was successfully deleted."
    redirect_to faces_path
  end

  def scrape
    Face.delete_all
    scrape_page "Academic"
    scrape_page "Administrative"
    scrape_page "Technical"
    update_rooms
    redirect_to faces_path
  end

  def toggle_visible
    @face = Face.find(params[:face])
    @visible = !@face.visible
    @face.update_attribute(:visible, @visible)
  end

  private
    def get_face
      @face = Face.find(params[:id])
    end

    def face_params
      params.require(:face).permit(:name, :_type, :position, :modules, :room, :email, :phone, :photo, :visible, :ovr_name, :ovr_type, :ovr_position, :ovr_modules, :ovr_room, :ovr_email, :ovr_phone, :ovr_photo)
    end

  def scrape_page(type)
    field = type.to_s.downcase # academic, administrative or technical
    uri = 'https://www.nottingham.ac.uk/computerscience/people/' # the URL to scrape from
    page = Nokogiri::HTML(HTTParty.get(uri)) # the page source
    page.at_css("div#lookup-#{field}").css('tr').map do |row| # for each row in the details table
      if row.css('th').text.to_s.include?('Academic Staff in Malaysia') # do not scrape international staff details
        break
      end
      unless row.css('a')[0].nil?
        unless row.css('td')[0].css('a')[0]['href'].include? 'mailto:'
          names = row.css('td')[0].css('a')[0].text.to_s.split(', ') # extract name
          first_name = names[1].delete(' ')
          last_name = names[0].delete(' ')
          webpage = uri + row.css('td')[0].css('a')[0]['href'] # extract academic webpage
          name = first_name + ' ' + last_name
          contact = row.css('td')[1].text.to_s.gsub(/\s+/, "") # extract contact number
          title = row.css('td')[2].text # extract role in school
          email = row.css('a')[0]['href'] + '@nottingham.ac.uk' # extract email address
          image_url = uri + 'staff-images/' + first_name.downcase + last_name.downcase + '.jpg' # extract portrait photo
          Face.create(:name => name, :room => "None", :modules => "None", :email => email, :photo => image_url, :phone => contact, :position => title, :_type => type, :url => webpage)
        end
      end
    end
  end

  def scrape_room(webpage)
    page = Nokogiri::HTML(HTTParty.get(webpage)) # the page source
    address_line = page.at_css("div#lookup-personal-details").css('span.street-address').first.to_s # extract the first line of staff member's address
    temp = address_line.split(">")[1].to_s # remove HTML tags
    temp = temp.split("<")[0]
    if temp.to_s.include? '&amp;'
      temp.to_s.sub! '&amp;', '&' # fix encoding issues
    end
    if temp.to_s.length == 0
      temp = "None" # not all staff members have rooms
    end
    temp.to_s
  end

  def update_rooms
    Face.all.each do |f|
      f.room = scrape_room f.url
      f.save
    end
  end
end
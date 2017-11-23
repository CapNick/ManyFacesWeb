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
    @faces = Face.all
  end

  def new
    @face = Face.new
  end

  def edit
  end

  def update
    if @face.update(face_params)
      flash[:notice] = "Staff member was successfully updated."
      redirect_to face_path(@face)
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

  private
    def get_face
      @face = Face.find(params[:id])
    end

    def face_params
      params.require(:face).permit(:name, :_type, :position, :modules, :room, :email, :phone, :photo, :ovr_name, :ovr_type, :ovr_position, :ovr_modules, :ovr_room, :ovr_email, :ovr_phone, :ovr_photo)
    end

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
          name = first_name + ' ' + last_name
          contact = row.css('td')[1].text
          title = row.css('td')[2].text
          email = row.css('a')[0]['href'] + '@nottingham.ac.uk'
          image_url = uri + 'staff-images/' + first_name.downcase + last_name.downcase + '.jpg'
          Face.create(:name => name, :room => "None", :modules => "None", :email => email, :photo => image_url, :phone => contact, :position => title, :_type => type, :url => webpage)
        end
      end
    end
  end

  def update_rooms
    Face.all.each do |f|
      f.room = scrape_room f.url
      f.save
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
      temp = "None"
    end
    temp.to_s
  end
end
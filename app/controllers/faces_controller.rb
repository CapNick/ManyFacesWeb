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
    @faces = Face.order('name')
    @faces_all = Face.where(visible: true)
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
    @face._index = Face.count == 0 ? 0 : Face.order('_index DESC').first._index + 1
    if @face.save
      flash[:notice] = "Staff member was successfully created."
      redirect_to faces_path
    else
      # reload the /faces/new page
      render 'new'
    end
  end

  def show
  end

  def destroy
    old_index = @face._index
    @face.destroy
    flash[:notice] = "Staff member was successfully deleted."
    Face.where('_index > ?', old_index).update_all('_index = _index - 1')
    redirect_to faces_path
  end

  def scrape
    $order = 0
    scrape_page "Academic"
    scrape_page "Administrative"
    scrape_page "Technical"
    update_rooms
    redirect_to faces_path
  end

  def toggle_visible
    # find the face whose visibility to toggle
    @face = Face.find(params[:face])
    old_index = @face._index
    visible = !@face.visible
    # set index to -1 if now invisible
    # or the maximum index if now visible
    new_index = visible ? Face.order('_index DESC').first._index + 1 : -1
    @face.update_attributes(visible: visible, _index: new_index)
    unless visible
      # decrement all indexes that follow
      Face.where('_index > ?', old_index).update_all('_index = _index - 1')
    end

  end

  def reorder
    @faces = Face.where('_index >= ?', 0).order('_index')
    @layouts = Layout.order('width')
    @selected = Layout.where(selected: true).first
  end

  def update_order
    # update face indexes
    order = params[:order]
    index = 0
    order.each do |obj|
      if obj != 'blank'
        vals = obj.split('-')
        @face = Face.find(vals[0])
        unless @face._index == index
          @face.update_attribute(:_index, index)
        end
        unless @face.label == vals[1]
          @face.update_attribute(:label, vals[1])
        end
      end
      index += 1
    end

    # update dimensions
    width = params[:width]
    height = params[:height]
    @oldLayout = Layout.where(selected: true).first
    puts @oldLayout.width
    puts @oldLayout.height
    puts width
    puts height
    unless @oldLayout.width.to_s == width && @oldLayout.height.to_s == height
      @newLayout = Layout.where(width: width, height: height).first
      @oldLayout.selected = false
      @newLayout.selected = true
      @oldLayout.save
      @newLayout.save
    end
    redirect_to faces_path
  end

  private

  def get_face
    @face = Face.find(params[:id])
  end

  def face_params
    params.require(:face).permit(:name, :_type, :position, :room, :email, :phone, :photo, :model_file, :visible, :ovr_name, :ovr_type, :ovr_position, :ovr_room, :ovr_email, :ovr_phone, :ovr_photo, :remove_model_file)
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
          order = $order
          $order += 1
          @face = Face.all.where(name: name).first
          if @face
            # puts "updating existing..."
            @face.update_attributes(:email => email, :photo => image_url, :phone => contact, :position => title, :_type => type, :url => webpage)
          else
            # puts "creating new..."
            Face.create(:name => name, :room => "None", :email => email, :photo => image_url, :phone => contact, :position => title, :_type => type, :url => webpage, :_index => order, :label => "")
          end
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
    else
      if temp.start_with?('Room')
        temp.slice!(0, 5)
      end
    end
    temp.to_s
  end

  def update_rooms
    Face.all.each do |f|
      if f.url?
        f.room = scrape_room f.url
        f.save
      end
    end
  end
end
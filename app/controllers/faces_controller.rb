require 'httparty'
require 'nokogiri'
require 'spawnling'

class FacesController < ApplicationController

  include HTTParty
  include Nokogiri

  before_action :authenticate_user!, except: [:collection] # user must log in before the following actions
  before_action :get_face, only: [:edit, :update, :show, :destroy] # get the selected staff member from the Faces table before these actions

  # the /faces/collection.json page
  def collection
    @faces = Face.where(visible: true).order('_index ASC') # get all visible staff members, ordered by their position in the grid
  end

  # the root, 'view all staff' page
  def index
    @faces = Face.order('name') # get all staff members, ordered by their name
    @faces_all = Face.where(visible: true) # get only visible staff members
  end

  # the 'add new staff member' page
  def new
    @face = Face.new # create a new Face object
  end

  # the 'update staff member' page
  def edit
  end

  # update a staff member's details
  def update
    if @face.update(face_params) # if validation checks are passed
      flash[:notice] = "Staff member was successfully updated." # display a confirmation message
      redirect_to faces_path # return to the previous page
    else
      render 'edit' # otherwise, load any error messages
    end
  end

  # create a new staff member in the Faces table
  def create
    @face = Face.new(face_params) # create a new Face object
    @face._index = Face.count == 0 ? 0 : Face.order('_index DESC').first._index + 1 # give it a unique grid position
    if @face.room.empty?
      @face.room = "None" # use default room value
    end
    if @face.email.empty?
      @face.email = "None" # use default email value
    end
    if @face.phone.empty?
      @face.phone = "None" # use default contact number value
    end
    if @face.photo.empty?
      @face.photo = "None" # use default photo URL value
    end
    if @face.save # if the new record was accepted
      flash[:notice] = "Staff member was successfully created." # display a confirmation message
      redirect_to faces_path # return to the previous page
    else
      render 'new' # otherwise, load any error messages
    end
  end

  # deletes a staff member
  def destroy
    old_index = @face._index # get the grid position of the staff member
    @face.destroy # delete the staff member
    flash[:notice] = "Staff member was successfully deleted." # display a confirmation message
    Face.where('_index > ?', old_index).update_all('_index = _index - 1') # decrement the indexes of staff members that follow
    redirect_to faces_path # reload the page
  end

  # sync the Faces table with the UoN CS staff information website
  def scrape
    $order = 0 # set the initial grid position
    scrape_page "Academic" # scrape the CS academic staff web page
    scrape_page "Administrative" # scrape the CS admin staff web page
    scrape_page "Technical" # scrape the CS technical staff web page
    update_rooms # scrape the rooms of all staff members
    redirect_to faces_path # reload the page
  end

  # update the 'visibility' for a staff member
  def toggle_visible
    @face = Face.find(params[:face]) # find the staff member's Face object
    old_index = @face._index # get their current grid position
    visible = !@face.visible # toggle the 'visibility' value
    new_index = visible ? Face.order('_index DESC').first._index + 1 : -1 # set index to -1 if now invisible or the maximum index if now visible
    @face.update_attributes(visible: visible, _index: new_index) # apply changes
    unless visible # if staff member is now visible
      Face.where('_index > ?', old_index).update_all('_index = _index - 1') # decrement the position of staff members that follow
    end

  end

  # the 'layout customisation' page
  def reorder
    @faces = Face.where('_index >= ?', 0).order('_index') # get all visible staff members, ordered by their grid position
    @layouts = Layout.order('width') # get the list of selectable grid dimensions
    @selected = Layout.where(selected: true).first # get the currently selected grid dimensions
  end

  # updates the layout of the grid of staff members
  def update_order
    # updates staff member grid positions
    order = params[:order] # get the order, passed from the client
    index = 0 # set the initial grid position
    order.each do |obj| # for each grid element
      if obj != 'blank' # if the element is not a blank frame
        vals = obj.split('-')
        @face = Face.find(vals[0]) # get the next staff member
        unless @face._index == index # if their index is different
          @face.update_attribute(:_index, index) # update their index
        end
        unless @face.label == vals[1] # if their label is different
          @face.update_attribute(:label, vals[1]) # update their label
        end
      end
      index += 1 # increment the current grid position
    end

    # update grid dimensions
    width = params[:width] # get the selected width, passed from the client
    height = params[:height] # get the selected height, passed from the client
    @oldLayout = Layout.where(selected: true).first # get the Layout object that was previously selected
    unless @oldLayout.width.to_s == width && @oldLayout.height.to_s == height # unless the dimensions have not changed
      @newLayout = Layout.where(width: width, height: height).first # get the Layout object with the selected dimensions
      @oldLayout.selected = false # deselect the old Layout object in the table
      @newLayout.selected = true # select the new Layout object in the table
      @oldLayout.save # save both objects
      @newLayout.save
    end
    redirect_to faces_path # return to the previous page
  end

  private

  # gets the staff member object with the selected record 'id'
  def get_face
    @face = Face.find(params[:id])
  end

  def face_params
    params.require(:face).permit(:name, :_type, :position, :room, :email, :phone, :photo, :model_file, :visible, :ovr_name, :ovr_type, :ovr_position, :ovr_room, :ovr_email, :ovr_phone, :ovr_photo, :remove_model_file)
  end

  # pulls a group of staff members' information from the UoN CS website
  def scrape_page(type)
    field = type.to_s.downcase # academic, administrative or technical?
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
          $order += 1 # increment the next grid position
          @face = Face.all.where(name: name).first
          if @face # if the staff member already exists
            # puts "updating existing..."
            @face.update_attributes(:email => email, :photo => image_url, :phone => contact, :position => title, :_type => type, :url => webpage) # update the existing staff object
          else
            # puts "creating new..."
            Face.create(:name => name, :room => "None", :email => email, :photo => image_url, :phone => contact, :position => title, :_type => type, :url => webpage, :_index => order, :label => "") # otherwise create a new one
          end
        end
      end
    end
  end

  # pull a staff member's room from their personal website
  def scrape_room(webpage)
    page = Nokogiri::HTML(HTTParty.get(webpage)) # get the page source
    address_line = page.at_css("div#lookup-personal-details").css('span.street-address').first.to_s # extract the first line of staff member's address
    temp = address_line.split(">")[1].to_s # remove HTML tags
    temp = temp.split("<")[0]
    if temp.to_s.include? '&amp;'
      temp.to_s.sub! '&amp;', '&' # fix encoding issues
    end
    if temp.to_s.length == 0
      temp = "None" # not all staff members have rooms, so replace with 'None' if so
    else
      if temp.start_with?('Room') # remove the word 'room'
        temp.slice!(0, 5)
      end
    end
    temp.to_s
  end

  # update the rooms of all staff members in the Faces table
  def update_rooms
    Face.all.each do |f| # for all staff members
      if f.url? # if their personal website was previously scraped
        f.room = scrape_room f.url # scrape their room from it
        f.save
      end
    end
  end
end
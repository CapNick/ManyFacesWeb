class FacesController < ApplicationController

  # call the get_face method at the beginning of these actions
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

  private
    def get_face
      @face = Face.find(params[:id])
    end

    def face_params
      params.require(:face).permit(:name, :room, :modules, :email, :photo)
    end

end
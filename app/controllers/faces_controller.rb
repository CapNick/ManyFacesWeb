class FacesController < ApplicationController

  def new
    @face = Face.new
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
    @face = Face.find(params[:id])
  end

  private
    def face_params
      params.require(:face).permit(:name, :room, :modules, :email, :photo)
    end

end
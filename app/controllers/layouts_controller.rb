class LayoutsController < ApplicationController

  # the /layouts.json page
  def index
    @layouts = Layout.where(selected: true) # get the currently selected dimensions
  end
end
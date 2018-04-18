class LayoutsController < ApplicationController

  def index
    @layouts = Layout.where(selected: true)
  end
end
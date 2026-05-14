class PagesController < ApplicationController
  def home
    render :portfolio
  end

  def it_corporate
    render :home
  end

  def about; end
  def services; end
end

class MoviesController < ApplicationController

  def initialize
    @all_ratings = Movie.select('DISTINCT rating').map(&:rating)
    @checked = @all_ratings
    super
  end

  def all_ratings
    @all_ratings = Movie.select('DISTINCT rating').map(&:rating)
  end
  
  def checked
    if params.key?(:ratings)
      @checked = params[:ratings].keys
      session[:ratings] = Hash[@checked.map{|rating| [rating, 1]}]
    elsif session.key?(:ratings)
      @checked = session[:ratings]
    else
      @checked = @all_ratings
    end
  end

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def set_movies
    if params.key?(:ratings) and params[:ratings] != [] #not using blanked out checkboxes
      checked
      @movies = Movie.where({rating: params['ratings'].keys})
    elsif session.key?(:ratings)
      checked
      @movies = Movie.where({rating: session['ratings']})
    else
      @movies = Movie.all
    end
  end

  def redirect?
    sort = params.key?(:sort)? params[:sort] : session.key?(:sort) ? session[:sort] : ""
    ratings = params.key?(:ratings)? params[:ratings] : session.key?(:ratings) ? session[:ratings] : ""
    if sort != "" and ratings != ""
      flash.keep
      redirect_to movies_path(:ratings => ratings, :sort => sort)
    end
  end

  def index
    set_movies
    sort_field = params.key?(:sort)? params[:sort] : session.key?(:sort) ? session[:sort] : ""
    if sort_field != ""
      session[:sort] = sort_field #reset if was already set...
      @movies = @movies.order(sort_field)
      @title = sort_field == 'title'
      @date = sort_field == 'release_date'
    end
    redirect?
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
end

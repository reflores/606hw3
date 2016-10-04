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

  def index
    if params.key?(:ratings)
      checked
      @movies = Movie.where({rating: params['ratings'].keys})
    else
      @movies = Movie.all
    end
    if params.key?(:sort)
      field = params[:sort]
      @movies = @movies.order(field)
      @title = field == 'title'
      @date = field == 'release_date'
    end
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

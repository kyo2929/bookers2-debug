class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    view_count = ViewCount.new(book_id: @book.id, user_id: current_user.id)
    view_count.save

    @user = @book.user
    @book_new = Book.new
    @book_comment = BookComment.new

  end

  def index
    to = Time.current.at_end_of_day
    from = (to - 6.day).at_beginning_of_day
    @books = Book.includes(:favorited_users).sort_by {|x| x.favorited_users.includes(:favorites).where(created_at: from...to).size}.reverse
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title,:body,:star)
  end

  def ensure_correct_user
    book = Book.find(params[:id])
    @user = book.user
    unless @user.id == current_user.id
      redirect_to books_path
    end
  end

end

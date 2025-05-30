require 'json'

class Book
  attr_accessor :title, :author, :isbn, :count

  def initialize(title, author, isbn, count = 1)
    @title = title
    @author = author
    @isbn = isbn
    @count = count
  end

  def to_s
    "Title: #{title}, Author: #{author}, ISBN: #{isbn}, Count: #{count}"
  end

  def to_json
    { title: title, author: author, isbn: isbn, count: count }
  end

  def self.from_json(hash)
    new(hash['title'], hash['author'], hash['isbn'], hash['count'] || 1)
  end
end

class Inventory
  attr_accessor :books

  def initialize(books)
    @books = books
  end

  def load_from_file
    if File.exist?("test.json")
      data = JSON.parse(File.read("test.json"))
      @books = data.map { |book_hash| Book.from_json(book_hash) }
    end
  end

  def save_to_file
    book_hashes = @books.map { |book| book.to_json }
    File.open("test.json", 'w') do |f|
      f.write(JSON.pretty_generate(book_hashes))
    end
  end

  def list_books
    @books.each { |book| puts book.to_s }
  end

  def add_book(new_book)
    existing = @books.find { |book| book.isbn == new_book.isbn }
    if existing
      existing.count += new_book.count
      puts "Book with ISBN #{new_book.isbn} already exists. Increasing count to #{existing.count}."
    else
      @books << new_book
      puts "Added new book: #{new_book.title}"
    end
    save_to_file
  end

  def remove_by_isbn(isbn)
    book = @books.find { |b| b.isbn == isbn }
    if book
      if book.count > 1
        book.count -= 1
        puts "Decreased count of book with ISBN #{isbn}. New count: #{book.count}"
      else
        @books.delete(book)
        puts "Book with ISBN #{isbn} removed."
      end
      save_to_file
    else
      puts "No book found with ISBN #{isbn}."
    end
  end
end

inv = Inventory.new([])
inv.load_from_file

while true do
  puts "\n1: LIST\n2: ADD\n3: REMOVE\n4: EXIT"
  input = gets.chomp

  case input
  when "1"
    inv.list_books
  when "2"
    print "Enter title: "
    title = gets.chomp
    print "Enter author: "
    author = gets.chomp
    print "Enter ISBN: "
    isbn = gets.chomp
    print "Enter quantity: "
    quantity = gets.chomp.to_i
    quantity = 1 if quantity < 1
    inv.add_book(Book.new(title, author, isbn, quantity))
  when "3"
    print "Enter ISBN to remove: "
    isbn = gets.chomp
    inv.remove_by_isbn(isbn)
  when "4"
    break
  else
    puts "Invalid input."
  end
end


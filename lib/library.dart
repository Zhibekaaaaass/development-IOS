class Book {
  String title;
  String author;
  double price;
  bool isBorrowed;

  Book({
    required this.title,
    required this.author,
    required this.price,
    this.isBorrowed = false,
  });
}

class Library {
  List<Book> _books = [];

  void addBook(Book book) {
    _books.add(book);
  }

  List<Book> getAvailableBooks() {
    return _books
        .where((book) => book.isBorrowed == false)
        .toList();
  }

  double getTotalValue() {
    return _books.fold(
      0.0,
      (sum, book) => sum + book.price,
    );
  }
}

void main() {
  Library library = Library();

  Book book1 = Book(
    title: "Harry Potter",
    author: "J.K. Rowling",
    price: 5000.0,
  );

  Book book2 = Book(
    title: "The Hobbit",
    author: "J.R.R. Tolkien",
    price: 4500.0,
    isBorrowed: true,
  );

  Book book3 = Book(
    title: "1984",
    author: "George Orwell",
    price: 6000.0,
  );

  Book book4 = Book(
    title: "Clean Code",
    author: "Robert Martin",
    price: 7000.0,
    isBorrowed: true,
  );

  library.addBook(book1);
  library.addBook(book2);
  library.addBook(book3);
  library.addBook(book4);

  print("Available books:");

  for (Book book in library.getAvailableBooks()) {
    print("${book.title} - ${book.author} - ${book.price} ₸");
  }

  print("");

  print("Total collection value: ${library.getTotalValue()} ₸");
}
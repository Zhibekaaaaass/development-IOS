abstract class MediaItem {
  String id;
  String title;
  double price;

  MediaItem({
    required this.id,
    required this.title,
    required this.price,
  });

  String getDetails();
}

mixin Downloadable {
  void download(String title) {
    print("Downloading: $title");
  }
}

class Audiobook extends MediaItem with Downloadable {
  double durationHours;
  String narrator;

  Audiobook({
    required String id,
    required String title,
    required double price,
    required this.durationHours,
    required this.narrator,
  }) : super(
          id: id,
          title: title,
          price: price,
        );

  @override
  String getDetails() {
    return "Audiobook: $title, Narrator: $narrator, Duration: $durationHours hours, Price: $price ₸";
  }
}

class EBook extends MediaItem with Downloadable {
  double fileSizeMB;
  String author;

  EBook({
    required String id,
    required String title,
    required double price,
    required this.fileSizeMB,
    required this.author,
  }) : super(
          id: id,
          title: title,
          price: price,
        );

  @override
  String getDetails() {
    return "EBook: $title, Author: $author, File size: $fileSizeMB MB, Price: $price ₸";
  }
}

class ShoppingCart {
  List<MediaItem> _items = [];

  void addItem(MediaItem item) {
    _items.add(item);
  }

  double calculateTotalWithTax({double taxRate = 0.12}) {
    double total = _items.fold(
      0.0,
      (sum, item) => sum + item.price,
    );

    return total + total * taxRate;
  }

  List<MediaItem> filterByMaxPrice(double maxPrice) {
    return _items
        .where((item) => item.price <= maxPrice)
        .toList();
  }

void printReceipt() {
  print("Shopping Cart:");

  for (MediaItem item in _items) {
    print(item.getDetails());

    if (item is Downloadable) {
      (item as Downloadable).download(item.title);
    }
  }

  print("Total with tax: ${calculateTotalWithTax()} ₸");
}
}

void main() {
  Audiobook audiobook = Audiobook(
    id: "A001",
    title: "Harry Potter",
    price: 5000.0,
    durationHours: 8.5,
    narrator: "Jim Dale",
  );

  EBook ebook = EBook(
    id: "E001",
    title: "Clean Code",
    price: 7000.0,
    fileSizeMB: 5.2,
    author: "Robert Martin",
  );

  ShoppingCart cart = ShoppingCart();

  cart.addItem(audiobook);
  cart.addItem(ebook);

  cart.printReceipt();

  print("");
  print("Books under 6000 ₸:");

  List<MediaItem> cheapItems = cart.filterByMaxPrice(6000.0);

  for (MediaItem item in cheapItems) {
    print(item.getDetails());
  }
}
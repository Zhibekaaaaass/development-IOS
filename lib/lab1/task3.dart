void main() {
  String text = "flutter mobile development";

  int count = 0;

  for (int i = 0; i < text.length; i++) {
    String letter = text[i];

    if ("aeiou".contains(letter)) {
      count++;
    }
  }

  print("Количество гласных: $count");
}
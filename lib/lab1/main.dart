void main() {
  for (int number = 1; number <= 10; number++) {
    print("Таблица умножения на $number");

    for (int i = 1; i <= 10; i++) {
      print("$number * $i = ${number * i}");
    }

    print("");
  }
}
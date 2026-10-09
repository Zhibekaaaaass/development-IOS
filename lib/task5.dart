void main() {
  int number = 5;

  bool isPrime = true;

  if (number < 2) {
    isPrime = false;
  } else {
    for (int i = 2; i < number; i++) {
      if (number % i == 0) {
        isPrime = false;
        break;
      }
    }
  }

  if (isPrime) {
    print("$number -> prime number");
  } else {
    print("$number -> not prime number");
  }
}
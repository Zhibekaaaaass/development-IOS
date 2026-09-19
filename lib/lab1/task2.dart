void main() {
  int day = 28;
  int month = 2;
  int year = 2024;

  bool isLeapYear =
      year % 400 == 0 || (year % 4 == 0 && year % 100 != 0);

  int daysInMonth;

  if (month == 2) {
    if (isLeapYear) {
      daysInMonth = 29;
    } else {
      daysInMonth = 28;
    }
  } else if (month == 4 || month == 6 || month == 9 || month == 11) {
    daysInMonth = 30;
  } else if (month == 1 ||
      month == 3 ||
      month == 5 ||
      month == 7 ||
      month == 8 ||
      month == 10 ||
      month == 12) {
    daysInMonth = 31;
  } else {
    print("Invalid month");
    return;
  }

  if (day < 1 || day > daysInMonth) {
    print("Invalid date");
    return;
  }

  if (day < daysInMonth) {
    day++;
  } else {
    day = 1;

    if (month < 12) {
      month++;
    } else {
      month = 1;
      year++;
    }
  }

  print(
    "${day.toString().padLeft(2, '0')}."
    "${month.toString().padLeft(2, '0')}."
    "$year",
  );
}
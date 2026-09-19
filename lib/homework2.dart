void main() {
  String name = "Bekzat";
  double balance = 50000.0;

  checkBalance(
    name: name,
    balance: balance,
  );

  balance = deposit(
    currentBalance: balance,
    amount: 10000.0,
  );

  checkBalance(
    name: name,
    balance: balance,
  );

  balance = withdraw(
    name: name,
    currentBalance: balance,
    amount: 20000.0,
    pinCode: 1234,
  );

  checkBalance(
    name: name,
    balance: balance,
  );
}


void checkBalance({
  required String name,
  required double balance,
}) =>
    print("$name, your current available balance is: $balance");


double deposit({
  required double currentBalance,
  double? amount,
}) {
  double depositAmount = amount ?? 0.0;

  double newBalance = currentBalance + depositAmount;

  print("Deposit: $depositAmount");
  print("Deposit successful. New balance: $newBalance");

  return newBalance;
}


double withdraw({
  required String name,
  required double currentBalance,
  double? amount,
  int? pinCode,
}) {
  int enteredPin = pinCode ?? 0000;

  if (enteredPin != 1234) {
    print("$name, incorrect PIN. Transaction declined.");
    return currentBalance;
  }

  if (amount == null) {
    amount = 0.0;
  }

  double withdrawAmount = amount!;

  if (withdrawAmount > currentBalance) {
    print("Insufficient funds. Transaction declined.");
    return currentBalance;
  }

  double newBalance = currentBalance - withdrawAmount;

  print("Withdrawal: $withdrawAmount");
  print("Withdrawal successful. New balance: $newBalance");

  return newBalance;
}
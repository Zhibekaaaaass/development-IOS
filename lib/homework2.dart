void main() {
  String name = "Bekzat";
  double balance = 50000.0;

  // 1. Check balance
  checkBalance(
    name: name,
    balance: balance,
  );

  // 2. Deposit
  balance = deposit(
    currentBalance: balance,
    amount: 10000.0,
  );

  checkBalance(
    name: name,
    balance: balance,
  );

  // 3. Withdraw
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


// 1. Check Balance
// Arrow function =>
void checkBalance({
  required String name,
  required double balance,
}) =>
    print("$name, your current available balance is: $balance");


// 2. Deposit
double deposit({
  required double currentBalance,
  double? amount,
}) {
  // If amount is null, use 0.0
  double depositAmount = amount ?? 0.0;

  double newBalance = currentBalance + depositAmount;

  print("Deposit: $depositAmount");
  print("Deposit successful. New balance: $newBalance");

  return newBalance;
}


// 3. Withdraw
double withdraw({
  required String name,
  required double currentBalance,
  double? amount,
  int? pinCode,
}) {
  // If PIN is null, use 0000
  int enteredPin = pinCode ?? 0000;

  // Verify PIN
  if (enteredPin != 1234) {
    print("$name, incorrect PIN. Transaction declined.");
    return currentBalance;
  }

  // If amount is null, use 0.0
  if (amount == null) {
    amount = 0.0;
  }

  // ! tells Dart that amount is definitely not null
  double withdrawAmount = amount!;

  // Check balance
  if (withdrawAmount > currentBalance) {
    print("Insufficient funds. Transaction declined.");
    return currentBalance;
  }

  double newBalance = currentBalance - withdrawAmount;

  print("Withdrawal: $withdrawAmount");
  print("Withdrawal successful. New balance: $newBalance");

  return newBalance;
}
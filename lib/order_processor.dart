void main() {
  processOrder(
    orderId: "ORD-001",
    itemPrice: 10000.0,
    promoCode: "SAVE10",
    deliveryFee: 500.0,
  );
}

double processOrder({
  required String orderId,
  required double itemPrice,
  String? promoCode,
  double? deliveryFee,
}) {
  double delivery = deliveryFee ?? 500.0;

  double discount = 0.0;

  if (promoCode == "SAVE10") {
    discount = itemPrice * 0.10;
  }

  double finalTotal = itemPrice - discount + delivery;

  print("Order ID: $orderId");
  print("Item price: $itemPrice ₸");
  print("Promo code: ${promoCode ?? "None"}");
  print("Discount: $discount ₸");
  print("Delivery fee: $delivery ₸");
  print("Final total: $finalTotal ₸");

  return finalTotal;
}
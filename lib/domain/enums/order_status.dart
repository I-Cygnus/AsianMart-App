enum OrderStatus {
  placed,
  paymentPending,
  confirmed,
  cancelled;

  String get apiValue => switch (this) {
        OrderStatus.placed => 'PLACED',
        OrderStatus.paymentPending => 'PAYMENT_PENDING',
        OrderStatus.confirmed => 'CONFIRMED',
        OrderStatus.cancelled => 'CANCELLED',
      };

  static OrderStatus fromApi(String? value) {
    switch (value) {
      case 'PAYMENT_PENDING':
        return OrderStatus.paymentPending;
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      case 'PLACED':
      default:
        return OrderStatus.placed;
    }
  }
}

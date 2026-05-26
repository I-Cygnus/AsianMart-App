enum OrderStatus {
  pendingPayment(0.2),
  preparing(0.45),
  shipping(0.72),
  delivered(1.0);

  const OrderStatus(this.progress);

  final double progress;
}

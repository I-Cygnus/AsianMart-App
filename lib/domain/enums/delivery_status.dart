enum DeliveryStatus {
  accepted,
  preparing,
  inTransit,
  delivered;

  String get apiValue => switch (this) {
        DeliveryStatus.accepted => 'ACCEPTED',
        DeliveryStatus.preparing => 'PREPARING',
        DeliveryStatus.inTransit => 'IN_TRANSIT',
        DeliveryStatus.delivered => 'DELIVERED',
      };

  static DeliveryStatus? fromApi(String? value) {
    switch (value) {
      case 'ACCEPTED':
        return DeliveryStatus.accepted;
      case 'PREPARING':
        return DeliveryStatus.preparing;
      case 'IN_TRANSIT':
        return DeliveryStatus.inTransit;
      case 'DELIVERED':
        return DeliveryStatus.delivered;
      default:
        return null;
    }
  }
}

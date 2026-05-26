import 'package:asian_mart_app/domain/entities/cart_entry.dart';

class CartSnapshot {
  const CartSnapshot({
    required this.items,
    required this.guestToken,
  });

  final List<CartEntry> items;
  final String? guestToken;
}

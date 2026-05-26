class Address {
  const Address({
    required this.id,
    required this.addressName,
    required this.zipCode,
    required this.address1,
    required this.address2,
    required this.isDefault,
  });

  final int id;
  final String addressName;
  final String zipCode;
  final String address1;
  final String address2;
  final bool isDefault;

  String get fullAddress {
    final second = address2.trim();
    if (second.isEmpty) {
      return '$zipCode  $address1';
    }
    return '$zipCode  $address1 $second';
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    final info = (json['addressInfo'] as Map<String, dynamic>? ?? const {});
    return Address(
      id: (json['id'] as num?)?.toInt() ?? 0,
      addressName: json['addressName'] as String? ?? '',
      zipCode: info['zipCode'] as String? ?? '',
      address1: info['address1'] as String? ?? '',
      address2: info['address2'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

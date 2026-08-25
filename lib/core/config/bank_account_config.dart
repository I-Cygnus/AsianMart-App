class BankAccountConfig {
  BankAccountConfig._();

  static const String bankName = String.fromEnvironment(
    'BANK_NAME',
    defaultValue: '농협은행',
  );

  static const String accountNumber = String.fromEnvironment(
    'BANK_ACCOUNT_NUMBER',
    defaultValue: '301-0123-4567-89',
  );

  static const String accountHolder = String.fromEnvironment(
    'BANK_ACCOUNT_HOLDER',
    defaultValue: '조이월드',
  );
}

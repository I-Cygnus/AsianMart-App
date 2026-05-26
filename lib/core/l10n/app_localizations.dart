import 'package:flutter/material.dart';
import 'package:asian_mart_app/domain/enums/sort_mode.dart';

class AppLocalizations {
  const AppLocalizations(this._locale);

  final Locale _locale;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('ko'),
    Locale('en'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
    Locale('ja'),
  ];

  static const _strings = <String, Map<String, String>>{
    'navHome': {'ko': '상품', 'en': 'Products'},
    'navCart': {'ko': '장바구니', 'en': 'Cart'},
    'navWishlist': {'ko': '찜', 'en': 'Wishlist'},
    'navProfile': {'ko': '내 정보', 'en': 'Profile'},
    'searchProductHint': {
      'ko': '상품명이나 설명으로 검색',
      'en': 'Search by product name or description',
    },
    'sortRecommended': {'ko': '추천순', 'en': 'Recommended'},
    'sortLatest': {'ko': '최신순', 'en': 'Latest'},
    'sortLowPrice': {'ko': '낮은 가격순', 'en': 'Price: Low'},
    'sortHighPrice': {'ko': '높은 가격순', 'en': 'Price: High'},
    'productsTitle': {'ko': '실상품 목록', 'en': 'Catalog'},
    'helloGuest': {'ko': '게스트로 둘러보는 중', 'en': 'Browsing as guest'},
    'helloUser': {'ko': '환영합니다', 'en': 'Welcome back'},
    'cartTitle': {'ko': '장바구니', 'en': 'Cart'},
    'cartEmpty': {'ko': '장바구니가 비어 있습니다', 'en': 'Your cart is empty'},
    'cartEmptyDesc': {
      'ko': '상품을 담으면 여기에서 수량과 결제 대상을 관리할 수 있습니다.',
      'en': 'Add products and manage checkout items here.',
    },
    'wishlistTitle': {'ko': '찜 목록', 'en': 'Wishlist'},
    'wishlistEmpty': {
      'ko': '찜한 상품이 없습니다',
      'en': 'Your wishlist is empty',
    },
    'wishlistEmptyDesc': {
      'ko': '상품 카드의 하트를 눌러 관심상품을 저장하세요.',
      'en': 'Tap the heart on a product card to save it.',
    },
    'deleteLabel': {'ko': '삭제', 'en': 'Delete'},
    'orderAmount': {'ko': '선택 금액', 'en': 'Selected total'},
    'placeOrder': {'ko': '주문 진행', 'en': 'Continue to checkout'},
    'productDesc': {'ko': '상품 설명', 'en': 'Description'},
    'quantity': {'ko': '수량', 'en': 'Quantity'},
    'subtotal': {'ko': '합계', 'en': 'Subtotal'},
    'addToCart': {'ko': '장바구니 담기', 'en': 'Add to cart'},
    'buyNow': {'ko': '바로 주문', 'en': 'Buy now'},
    'outOfStock': {'ko': '주문 불가', 'en': 'Unavailable'},
    'checkoutTitle': {'ko': '주문 확인', 'en': 'Checkout'},
    'shippingAddress': {'ko': '기본 배송지', 'en': 'Default address'},
    'changeAddress': {'ko': '배송지 관리', 'en': 'Manage addresses'},
    'paymentMethod': {'ko': '결제 방식', 'en': 'Payment method'},
    'paymentAmount': {'ko': '결제 예상 금액', 'en': 'Estimated payment'},
    'productAmount': {'ko': '상품 금액', 'en': 'Product amount'},
    'discountAmount': {'ko': '할인 금액', 'en': 'Discount'},
    'shippingFee': {'ko': '배송비', 'en': 'Shipping'},
    'free': {'ko': '무료', 'en': 'Free'},
    'finalAmount': {'ko': '최종 결제 금액', 'en': 'Final payment'},
    'payLabel': {'ko': '주문 확정', 'en': 'Confirm order'},
    'payAmountLabel': {'ko': '총 결제 금액', 'en': 'Total payment'},
    'profileTitle': {'ko': '내 정보', 'en': 'Profile'},
    'wishlistLabel': {'ko': '찜', 'en': 'Wishlist'},
    'addressManage': {'ko': '배송지', 'en': 'Addresses'},
    'languageSettings': {'ko': '언어 설정', 'en': 'Language'},
    'selectLanguage': {'ko': '언어 선택', 'en': 'Select language'},
    'signIn': {'ko': '로그인', 'en': 'Sign in'},
    'signUp': {'ko': '회원가입', 'en': 'Sign up'},
    'signOut': {'ko': '로그아웃', 'en': 'Sign out'},
    'emailLabel': {'ko': '이메일', 'en': 'Email'},
    'passwordLabel': {'ko': '비밀번호', 'en': 'Password'},
    'nameLabel': {'ko': '이름', 'en': 'Name'},
    'phoneLabel': {'ko': '전화번호', 'en': 'Phone'},
    'addressNameLabel': {'ko': '배송지 이름', 'en': 'Address label'},
    'zipCodeLabel': {'ko': '우편번호', 'en': 'ZIP code'},
    'address1Label': {'ko': '기본 주소', 'en': 'Address line 1'},
    'address2Label': {'ko': '상세 주소', 'en': 'Address line 2'},
    'saveAddress': {'ko': '배송지 저장', 'en': 'Save address'},
    'addAddress': {'ko': '배송지 추가', 'en': 'Add address'},
    'defaultAddress': {'ko': '기본 배송지', 'en': 'Default'},
    'setDefaultAddress': {'ko': '기본으로 설정', 'en': 'Set as default'},
    'noAddresses': {'ko': '등록된 배송지가 없습니다', 'en': 'No saved address'},
    'noAddressesDesc': {
      'ko': '주문을 진행하려면 최소 한 개의 배송지가 필요합니다.',
      'en': 'You need at least one address before placing an order.',
    },
    'bankTransfer': {'ko': '무통장 입금', 'en': 'Bank transfer'},
    'orderNoteLabel': {'ko': '요청사항', 'en': 'Order note'},
    'orderNoteHint': {
      'ko': '예: 문 앞에 놓아주세요',
      'en': 'Example: Leave it at the door',
    },
    'authRequiredTitle': {'ko': '로그인이 필요합니다', 'en': 'Sign in required'},
    'authRequiredDesc': {
      'ko': '이 기능은 회원 전용입니다. 로그인하거나 새 계정을 만들어 주세요.',
      'en': 'This feature is for signed-in users. Log in or create an account.',
    },
    'profileGuestTitle': {'ko': '회원 정보를 불러오지 못했습니다', 'en': 'No account loaded'},
    'profileGuestDesc': {
      'ko': '로그인하면 찜 목록, 배송지, 주문 기능을 실제로 사용할 수 있습니다.',
      'en': 'Sign in to use wishlist, addresses, and checkout.',
    },
    'retry': {'ko': '다시 시도', 'en': 'Retry'},
    'loginSubtitle': {
      'ko': '상품은 게스트로 볼 수 있지만 주문과 찜은 로그인 후 사용할 수 있습니다.',
      'en': 'You can browse as a guest, but wishlist and checkout require sign-in.',
    },
    'signupSubtitle': {
      'ko': '가입 후 바로 로그인되어 실제 장바구니와 배송지를 사용할 수 있습니다.',
      'en': 'After signing up, you can use your real cart and addresses.',
    },
    'pullToRefresh': {'ko': '아래로 당겨 새로고침', 'en': 'Pull to refresh'},
  };

  String _s(String key) =>
      _strings[key]?[_locale.languageCode] ?? _strings[key]?['ko'] ?? key;

  String get navHome => _s('navHome');
  String get navCart => _s('navCart');
  String get navWishlist => _s('navWishlist');
  String get navProfile => _s('navProfile');
  String get searchProductHint => _s('searchProductHint');
  String get productsTitle => _s('productsTitle');
  String get helloGuest => _s('helloGuest');
  String get helloUser => _s('helloUser');
  String get cartTitle => _s('cartTitle');
  String get cartEmpty => _s('cartEmpty');
  String get cartEmptyDesc => _s('cartEmptyDesc');
  String get wishlistTitle => _s('wishlistTitle');
  String get wishlistEmpty => _s('wishlistEmpty');
  String get wishlistEmptyDesc => _s('wishlistEmptyDesc');
  String get deleteLabel => _s('deleteLabel');
  String get orderAmount => _s('orderAmount');
  String get placeOrder => _s('placeOrder');
  String get productDesc => _s('productDesc');
  String get quantity => _s('quantity');
  String get subtotal => _s('subtotal');
  String get addToCart => _s('addToCart');
  String get buyNow => _s('buyNow');
  String get outOfStock => _s('outOfStock');
  String get checkoutTitle => _s('checkoutTitle');
  String get shippingAddress => _s('shippingAddress');
  String get changeAddress => _s('changeAddress');
  String get paymentMethod => _s('paymentMethod');
  String get paymentAmount => _s('paymentAmount');
  String get productAmount => _s('productAmount');
  String get discountAmount => _s('discountAmount');
  String get shippingFee => _s('shippingFee');
  String get free => _s('free');
  String get finalAmount => _s('finalAmount');
  String get payLabel => _s('payLabel');
  String get payAmountLabel => _s('payAmountLabel');
  String get profileTitle => _s('profileTitle');
  String get wishlistLabel => _s('wishlistLabel');
  String get addressManage => _s('addressManage');
  String get languageSettings => _s('languageSettings');
  String get selectLanguage => _s('selectLanguage');
  String get signIn => _s('signIn');
  String get signUp => _s('signUp');
  String get signOut => _s('signOut');
  String get emailLabel => _s('emailLabel');
  String get passwordLabel => _s('passwordLabel');
  String get nameLabel => _s('nameLabel');
  String get phoneLabel => _s('phoneLabel');
  String get addressNameLabel => _s('addressNameLabel');
  String get zipCodeLabel => _s('zipCodeLabel');
  String get address1Label => _s('address1Label');
  String get address2Label => _s('address2Label');
  String get saveAddress => _s('saveAddress');
  String get addAddress => _s('addAddress');
  String get defaultAddress => _s('defaultAddress');
  String get setDefaultAddress => _s('setDefaultAddress');
  String get noAddresses => _s('noAddresses');
  String get noAddressesDesc => _s('noAddressesDesc');
  String get bankTransfer => _s('bankTransfer');
  String get orderNoteLabel => _s('orderNoteLabel');
  String get orderNoteHint => _s('orderNoteHint');
  String get authRequiredTitle => _s('authRequiredTitle');
  String get authRequiredDesc => _s('authRequiredDesc');
  String get profileGuestTitle => _s('profileGuestTitle');
  String get profileGuestDesc => _s('profileGuestDesc');
  String get retry => _s('retry');
  String get loginSubtitle => _s('loginSubtitle');
  String get signupSubtitle => _s('signupSubtitle');
  String get pullToRefresh => _s('pullToRefresh');

  String sortModeLabel(SortMode mode) => switch (mode) {
        SortMode.recommended => _s('sortRecommended'),
        SortMode.latest => _s('sortLatest'),
        SortMode.lowPrice => _s('sortLowPrice'),
        SortMode.highPrice => _s('sortHighPrice'),
      };

  String productCount(int count) => switch (_locale.languageCode) {
        'en' => '$count items',
        _ => '상품 $count개',
      };

  String itemQty(int quantity) => switch (_locale.languageCode) {
        'en' => 'Qty $quantity',
        _ => '$quantity개',
      };

  String addedToCart(String name, int qty) => switch (_locale.languageCode) {
        'en' => '$name x$qty added to cart',
        _ => '$name $qty개를 장바구니에 담았습니다.',
      };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ko', 'en', 'th', 'vi', 'zh', 'ja'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

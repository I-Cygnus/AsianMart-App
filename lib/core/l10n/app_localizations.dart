import 'package:flutter/material.dart';
import 'package:asian_mart_app/domain/enums/delivery_status.dart';
import 'package:asian_mart_app/domain/enums/order_status.dart';
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
    // ── Navigation ────────────────────────────────────────────────────────────
    'navHome': {
      'ko': '홈',
      'en': 'Home',
      'th': 'หน้าแรก',
      'vi': 'Trang chủ',
      'zh': '首页',
      'ja': 'ホーム',
    },
    'navProducts': {
      'ko': '상품',
      'en': 'Products',
      'th': 'สินค้า',
      'vi': 'Sản phẩm',
      'zh': '商品',
      'ja': '商品',
    },
    'navCart': {
      'ko': '장바구니',
      'en': 'Cart',
      'th': 'ตะกร้า',
      'vi': 'Giỏ hàng',
      'zh': '购物车',
      'ja': 'カート',
    },
    'navWishlist': {
      'ko': '찜',
      'en': 'Wishlist',
      'th': 'รายการโปรด',
      'vi': 'Yêu thích',
      'zh': '收藏',
      'ja': 'お気に入り',
    },
    'navProfile': {
      'ko': '내 정보',
      'en': 'Profile',
      'th': 'โปรไฟล์',
      'vi': 'Hồ sơ',
      'zh': '我的',
      'ja': 'マイページ',
    },

    // ── Home ─────────────────────────────────────────────────────────────────
    'searchProductHint': {
      'ko': '상품명이나 설명으로 검색',
      'en': 'Search by product name or description',
      'th': 'ค้นหาตามชื่อหรือคำอธิบายสินค้า',
      'vi': 'Tìm theo tên hoặc mô tả sản phẩm',
      'zh': '按商品名称或描述搜索',
      'ja': '商品名や説明で検索',
    },
    'pullToRefresh': {
      'ko': '아래로 당겨 새로고침',
      'en': 'Pull to refresh',
      'th': 'ดึงลงเพื่อรีเฟรช',
      'vi': 'Kéo xuống để làm mới',
      'zh': '下拉刷新',
      'ja': '引っ張って更新',
    },
    'retry': {
      'ko': '다시 시도',
      'en': 'Retry',
      'th': 'ลองอีกครั้ง',
      'vi': 'Thử lại',
      'zh': '重试',
      'ja': '再試行',
    },
    'sortRecommended': {
      'ko': '추천순',
      'en': 'Recommended',
      'th': 'แนะนำ',
      'vi': 'Đề xuất',
      'zh': '推荐',
      'ja': 'おすすめ順',
    },
    'sortLatest': {
      'ko': '최신순',
      'en': 'Latest',
      'th': 'ล่าสุด',
      'vi': 'Mới nhất',
      'zh': '最新',
      'ja': '新着順',
    },
    'sortLowPrice': {
      'ko': '낮은 가격순',
      'en': 'Price: Low',
      'th': 'ราคา: ต่ำ',
      'vi': 'Giá: Thấp',
      'zh': '价格从低到高',
      'ja': '価格: 安い順',
    },
    'sortHighPrice': {
      'ko': '높은 가격순',
      'en': 'Price: High',
      'th': 'ราคา: สูง',
      'vi': 'Giá: Cao',
      'zh': '价格从高到低',
      'ja': '価格: 高い順',
    },

    // ── Cart ─────────────────────────────────────────────────────────────────
    'cartTitle': {
      'ko': '장바구니',
      'en': 'Cart',
      'th': 'ตะกร้าสินค้า',
      'vi': 'Giỏ hàng',
      'zh': '购物车',
      'ja': 'カート',
    },
    'cartEmpty': {
      'ko': '장바구니가 비어 있습니다',
      'en': 'Your cart is empty',
      'th': 'ตะกร้าสินค้าว่างเปล่า',
      'vi': 'Giỏ hàng của bạn trống',
      'zh': '购物车是空的',
      'ja': 'カートが空です',
    },
    'cartEmptyDesc': {
      'ko': '상품을 담으면 여기에서 수량과 결제 대상을 관리할 수 있습니다.',
      'en': 'Add products and manage checkout items here.',
      'th': 'เพิ่มสินค้าและจัดการรายการชำระเงินได้ที่นี่',
      'vi': 'Thêm sản phẩm và quản lý các mặt hàng thanh toán tại đây.',
      'zh': '添加商品并在此管理结算商品。',
      'ja': '商品を追加してお支払い対象を管理できます。',
    },
    'orderAmount': {
      'ko': '선택 금액',
      'en': 'Selected total',
      'th': 'ยอดรวมที่เลือก',
      'vi': 'Tổng đã chọn',
      'zh': '已选金额',
      'ja': '選択合計',
    },
    'placeOrder': {
      'ko': '주문 진행',
      'en': 'Continue to checkout',
      'th': 'ดำเนินการสั่งซื้อ',
      'vi': 'Tiến hành đặt hàng',
      'zh': '继续结算',
      'ja': '注文に進む',
    },

    // ── Wishlist ──────────────────────────────────────────────────────────────
    'wishlistTitle': {
      'ko': '찜 목록',
      'en': 'Wishlist',
      'th': 'รายการโปรด',
      'vi': 'Danh sách yêu thích',
      'zh': '收藏列表',
      'ja': 'お気に入りリスト',
    },
    'wishlistEmpty': {
      'ko': '찜한 상품이 없습니다',
      'en': 'Your wishlist is empty',
      'th': 'รายการโปรดว่างเปล่า',
      'vi': 'Danh sách yêu thích của bạn trống',
      'zh': '收藏列表为空',
      'ja': 'お気に入りがありません',
    },
    'wishlistEmptyDesc': {
      'ko': '상품 카드의 하트를 눌러 관심상품을 저장하세요.',
      'en': 'Tap the heart on a product card to save it.',
      'th': 'แตะที่หัวใจบนการ์ดสินค้าเพื่อบันทึก',
      'vi': 'Nhấn vào trái tim trên thẻ sản phẩm để lưu.',
      'zh': '点击商品卡上的爱心来收藏。',
      'ja': '商品カードのハートをタップして保存できます。',
    },

    // ── Product Detail ────────────────────────────────────────────────────────
    'productDesc': {
      'ko': '상품 설명',
      'en': 'Description',
      'th': 'รายละเอียดสินค้า',
      'vi': 'Mô tả sản phẩm',
      'zh': '商品描述',
      'ja': '商品説明',
    },
    'quantity': {
      'ko': '수량',
      'en': 'Quantity',
      'th': 'จำนวน',
      'vi': 'Số lượng',
      'zh': '数量',
      'ja': '数量',
    },
    'subtotal': {
      'ko': '합계',
      'en': 'Subtotal',
      'th': 'ยอดรวม',
      'vi': 'Tổng cộng',
      'zh': '小计',
      'ja': '小計',
    },
    'addToCart': {
      'ko': '장바구니 담기',
      'en': 'Add to cart',
      'th': 'เพิ่มในตะกร้า',
      'vi': 'Thêm vào giỏ',
      'zh': '加入购物车',
      'ja': 'カートに追加',
    },
    'buyNow': {
      'ko': '바로 주문',
      'en': 'Buy now',
      'th': 'ซื้อเลย',
      'vi': 'Mua ngay',
      'zh': '立即购买',
      'ja': '今すぐ購入',
    },

    // ── Checkout ─────────────────────────────────────────────────────────────
    'checkoutTitle': {
      'ko': '주문 확인',
      'en': 'Checkout',
      'th': 'ยืนยันคำสั่งซื้อ',
      'vi': 'Xác nhận đơn hàng',
      'zh': '确认订单',
      'ja': '注文確認',
    },
    'shippingAddress': {
      'ko': '기본 배송지',
      'en': 'Default address',
      'th': 'ที่อยู่จัดส่งหลัก',
      'vi': 'Địa chỉ mặc định',
      'zh': '默认收货地址',
      'ja': 'デフォルト住所',
    },
    'changeAddress': {
      'ko': '배송지 관리',
      'en': 'Manage addresses',
      'th': 'จัดการที่อยู่',
      'vi': 'Quản lý địa chỉ',
      'zh': '管理收货地址',
      'ja': '住所管理',
    },
    'paymentMethod': {
      'ko': '결제 방식',
      'en': 'Payment method',
      'th': 'วิธีชำระเงิน',
      'vi': 'Phương thức thanh toán',
      'zh': '支付方式',
      'ja': '支払い方法',
    },
    'bankTransfer': {
      'ko': '무통장 입금',
      'en': 'Bank transfer',
      'th': 'โอนเงินผ่านธนาคาร',
      'vi': 'Chuyển khoản ngân hàng',
      'zh': '银行转账',
      'ja': '銀行振込',
    },
    'orderNoteLabel': {
      'ko': '요청사항',
      'en': 'Order note',
      'th': 'หมายเหตุ',
      'vi': 'Ghi chú đơn hàng',
      'zh': '订单备注',
      'ja': 'ご要望',
    },
    'orderNoteHint': {
      'ko': '예: 문 앞에 놓아주세요',
      'en': 'Example: Leave it at the door',
      'th': 'ตัวอย่าง: วางไว้หน้าประตู',
      'vi': 'Ví dụ: Để trước cửa',
      'zh': '例如：放在门口',
      'ja': '例：玄関前に置いてください',
    },
    'paymentAmount': {
      'ko': '결제 예상 금액',
      'en': 'Estimated payment',
      'th': 'ยอดชำระโดยประมาณ',
      'vi': 'Thanh toán dự kiến',
      'zh': '预计付款金额',
      'ja': 'お支払い予定金額',
    },
    'productAmount': {
      'ko': '상품 금액',
      'en': 'Product amount',
      'th': 'ราคาสินค้า',
      'vi': 'Tiền hàng',
      'zh': '商品金额',
      'ja': '商品金額',
    },
    'shippingFee': {
      'ko': '배송비',
      'en': 'Shipping',
      'th': 'ค่าจัดส่ง',
      'vi': 'Phí vận chuyển',
      'zh': '运费',
      'ja': '配送料',
    },
    'free': {
      'ko': '무료',
      'en': 'Free',
      'th': 'ฟรี',
      'vi': 'Miễn phí',
      'zh': '免费',
      'ja': '無料',
    },
    'finalAmount': {
      'ko': '최종 결제 금액',
      'en': 'Final payment',
      'th': 'ยอดชำระสุดท้าย',
      'vi': 'Thanh toán cuối cùng',
      'zh': '最终付款金额',
      'ja': '最終お支払い金額',
    },
    'payLabel': {
      'ko': '주문 확정',
      'en': 'Confirm order',
      'th': 'ยืนยันคำสั่งซื้อ',
      'vi': 'Xác nhận đơn hàng',
      'zh': '确认订单',
      'ja': '注文を確定する',
    },

    // ── Profile ───────────────────────────────────────────────────────────────
    'profileTitle': {
      'ko': '내 정보',
      'en': 'Profile',
      'th': 'ข้อมูลของฉัน',
      'vi': 'Thông tin của tôi',
      'zh': '我的信息',
      'ja': 'マイページ',
    },
    'signOut': {
      'ko': '로그아웃',
      'en': 'Sign out',
      'th': 'ออกจากระบบ',
      'vi': 'Đăng xuất',
      'zh': '退出登录',
      'ja': 'ログアウト',
    },
    'addressManage': {
      'ko': '배송지',
      'en': 'Addresses',
      'th': 'ที่อยู่จัดส่ง',
      'vi': 'Địa chỉ',
      'zh': '收货地址',
      'ja': '配送先住所',
    },
    'languageSettings': {
      'ko': '언어 설정',
      'en': 'Language',
      'th': 'ตั้งค่าภาษา',
      'vi': 'Cài đặt ngôn ngữ',
      'zh': '语言设置',
      'ja': '言語設定',
    },
    'selectLanguage': {
      'ko': '언어 선택',
      'en': 'Select language',
      'th': 'เลือกภาษา',
      'vi': 'Chọn ngôn ngữ',
      'zh': '选择语言',
      'ja': '言語を選択',
    },

    // ── Address ───────────────────────────────────────────────────────────────
    'addAddress': {
      'ko': '배송지 추가',
      'en': 'Add address',
      'th': 'เพิ่มที่อยู่',
      'vi': 'Thêm địa chỉ',
      'zh': '添加地址',
      'ja': '住所を追加',
    },
    'addressNameLabel': {
      'ko': '배송지 이름',
      'en': 'Address label',
      'th': 'ชื่อที่อยู่',
      'vi': 'Tên địa chỉ',
      'zh': '地址名称',
      'ja': '住所ラベル',
    },
    'address2Label': {
      'ko': '상세 주소',
      'en': 'Address line 2',
      'th': 'รายละเอียดที่อยู่',
      'vi': 'Chi tiết địa chỉ',
      'zh': '详细地址',
      'ja': '詳細住所',
    },
    'saveAddress': {
      'ko': '배송지 저장',
      'en': 'Save address',
      'th': 'บันทึกที่อยู่',
      'vi': 'Lưu địa chỉ',
      'zh': '保存地址',
      'ja': '住所を保存',
    },
    'defaultAddress': {
      'ko': '기본 배송지',
      'en': 'Default',
      'th': 'ที่อยู่หลัก',
      'vi': 'Mặc định',
      'zh': '默认',
      'ja': 'デフォルト',
    },
    'setDefaultAddress': {
      'ko': '기본으로 설정',
      'en': 'Set as default',
      'th': 'ตั้งเป็นหลัก',
      'vi': 'Đặt làm mặc định',
      'zh': '设为默认',
      'ja': 'デフォルトに設定',
    },
    'noAddresses': {
      'ko': '등록된 배송지가 없습니다',
      'en': 'No saved address',
      'th': 'ไม่มีที่อยู่ที่บันทึกไว้',
      'vi': 'Không có địa chỉ đã lưu',
      'zh': '没有保存的地址',
      'ja': '保存された住所がありません',
    },
    'noAddressesDesc': {
      'ko': '주문을 진행하려면 최소 한 개의 배송지가 필요합니다.',
      'en': 'You need at least one address before placing an order.',
      'th': 'คุณต้องมีอย่างน้อยหนึ่งที่อยู่ก่อนสั่งซื้อ',
      'vi': 'Bạn cần ít nhất một địa chỉ trước khi đặt hàng.',
      'zh': '下单前需要至少一个收货地址。',
      'ja': '注文前に少なくとも1つの住所が必要です。',
    },

    // ── Auth ─────────────────────────────────────────────────────────────────
    'signIn': {
      'ko': '로그인',
      'en': 'Sign in',
      'th': 'เข้าสู่ระบบ',
      'vi': 'Đăng nhập',
      'zh': '登录',
      'ja': 'ログイン',
    },
    'signUp': {
      'ko': '회원가입',
      'en': 'Sign up',
      'th': 'สมัครสมาชิก',
      'vi': 'Đăng ký',
      'zh': '注册',
      'ja': '会員登録',
    },
    'emailLabel': {
      'ko': '이메일',
      'en': 'Email',
      'th': 'อีเมล',
      'vi': 'Email',
      'zh': '邮箱',
      'ja': 'メールアドレス',
    },
    'passwordLabel': {
      'ko': '비밀번호',
      'en': 'Password',
      'th': 'รหัสผ่าน',
      'vi': 'Mật khẩu',
      'zh': '密码',
      'ja': 'パスワード',
    },
    'nameLabel': {
      'ko': '이름',
      'en': 'Name',
      'th': 'ชื่อ',
      'vi': 'Họ tên',
      'zh': '姓名',
      'ja': '氏名',
    },
    'phoneLabel': {
      'ko': '전화번호',
      'en': 'Phone',
      'th': 'หมายเลขโทรศัพท์',
      'vi': 'Số điện thoại',
      'zh': '电话号码',
      'ja': '電話番号',
    },
    'authRequiredTitle': {
      'ko': '로그인이 필요합니다',
      'en': 'Sign in required',
      'th': 'กรุณาเข้าสู่ระบบ',
      'vi': 'Yêu cầu đăng nhập',
      'zh': '需要登录',
      'ja': 'ログインが必要です',
    },
    'authRequiredDesc': {
      'ko': '이 기능은 회원 전용입니다. 로그인하거나 새 계정을 만들어 주세요.',
      'en': 'This feature is for signed-in users. Log in or create an account.',
      'th': 'ฟีเจอร์นี้สำหรับสมาชิกเท่านั้น กรุณาเข้าสู่ระบบหรือสร้างบัญชี',
      'vi': 'Tính năng này dành cho thành viên. Vui lòng đăng nhập hoặc tạo tài khoản.',
      'zh': '此功能仅限会员使用。请登录或创建账号。',
      'ja': 'この機能は会員限定です。ログインまたは新規登録をしてください。',
    },
    'profileGuestDesc': {
      'ko': '로그인하면 찜 목록, 배송지, 주문 기능을 실제로 사용할 수 있습니다.',
      'en': 'Sign in to use wishlist, addresses, and checkout.',
      'th': 'เข้าสู่ระบบเพื่อใช้รายการโปรด ที่อยู่ และชำระเงิน',
      'vi': 'Đăng nhập để sử dụng danh sách yêu thích, địa chỉ và thanh toán.',
      'zh': '登录后可使用收藏、地址和结算功能。',
      'ja': 'ログインするとお気に入り、住所、注文機能が使えます。',
    },
    'orderInquiry': {
      'ko': '주문조회',
      'en': 'Order history',
      'th': 'ประวัติคำสั่งซื้อ',
      'vi': 'Tra cứu đơn hàng',
      'zh': '订单查询',
      'ja': '注文履歴',
    },
    'orderInquiryEmpty': {
      'ko': '주문 내역이 없습니다',
      'en': 'No orders yet',
      'th': 'ยังไม่มีคำสั่งซื้อ',
      'vi': 'Chưa có đơn hàng',
      'zh': '暂无订单',
      'ja': '注文履歴がありません',
    },
    'orderInquiryEmptyDesc': {
      'ko': '주문한 상품이 있으면 여기에서 진행 상태를 확인할 수 있습니다.',
      'en': 'Placed orders will appear here with their status.',
      'th': 'คำสั่งซื้อของคุณจะแสดงที่นี่พร้อมสถานะ',
      'vi': 'Đơn hàng đã đặt sẽ xuất hiện ở đây kèm trạng thái.',
      'zh': '已下订单会在此显示进度。',
      'ja': '注文した商品の進行状況をここで確認できます。',
    },
    'orderInquiryAuthDesc': {
      'ko': '주문 내역은 로그인 후 확인할 수 있어요.',
      'en': 'Sign in to view your order history.',
      'th': 'เข้าสู่ระบบเพื่อดูประวัติคำสั่งซื้อ',
      'vi': 'Đăng nhập để xem lịch sử đơn hàng.',
      'zh': '登录后可查看订单记录。',
      'ja': 'ログインすると注文履歴を確認できます。',
    },
    'orderDetailTitle': {
      'ko': '주문 상세',
      'en': 'Order detail',
      'th': 'รายละเอียดคำสั่งซื้อ',
      'vi': 'Chi tiết đơn hàng',
      'zh': '订单详情',
      'ja': '注文詳細',
    },
    'orderNumber': {
      'ko': '주문번호',
      'en': 'Order no.',
      'th': 'หมายเลขคำสั่งซื้อ',
      'vi': 'Mã đơn hàng',
      'zh': '订单号',
      'ja': '注文番号',
    },
    'orderDateLabel': {
      'ko': '주문일시',
      'en': 'Ordered at',
      'th': 'วันที่สั่งซื้อ',
      'vi': 'Ngày đặt',
      'zh': '下单时间',
      'ja': '注文日時',
    },
    'orderItems': {
      'ko': '주문 상품',
      'en': 'Items',
      'th': 'สินค้าที่สั่ง',
      'vi': 'Sản phẩm',
      'zh': '订购商品',
      'ja': '注文商品',
    },
    'recipientInfo': {
      'ko': '받는 분 정보',
      'en': 'Recipient',
      'th': 'ผู้รับ',
      'vi': 'Người nhận',
      'zh': '收件人信息',
      'ja': 'お受け取りの方',
    },
    'noOrderNote': {
      'ko': '요청사항이 없습니다',
      'en': 'No order note',
      'th': 'ไม่มีหมายเหตุ',
      'vi': 'Không có ghi chú',
      'zh': '没有备注',
      'ja': 'ご要望はありません',
    },
    'orderPlacedTitle': {
      'ko': '주문이 접수되었습니다',
      'en': 'Order placed',
      'th': 'รับคำสั่งซื้อแล้ว',
      'vi': 'Đã nhận đơn hàng',
      'zh': '订单已提交',
      'ja': '注文を受け付けました',
    },
    'orderPlacedDesc': {
      'ko': '주문조회에서 진행 상태를 확인할 수 있습니다.',
      'en': 'You can check the status in Order history.',
      'th': 'ตรวจสอบสถานะได้ที่ประวัติคำสั่งซื้อ',
      'vi': 'Bạn có thể xem trạng thái trong lịch sử đơn hàng.',
      'zh': '可在订单查询中查看进度。',
      'ja': '注文履歴で進行状況を確認できます。',
    },
    'orderStatusPlaced': {
      'ko': '주문 접수',
      'en': 'Placed',
      'th': 'รับคำสั่งซื้อแล้ว',
      'vi': 'Đã đặt',
      'zh': '已下单',
      'ja': '注文受付',
    },
    'orderStatusPaymentPending': {
      'ko': '입금 대기',
      'en': 'Awaiting payment',
      'th': 'รอชำระเงิน',
      'vi': 'Chờ thanh toán',
      'zh': '待付款',
      'ja': '入金待ち',
    },
    'orderStatusConfirmed': {
      'ko': '주문 확인',
      'en': 'Confirmed',
      'th': 'ยืนยันแล้ว',
      'vi': 'Đã xác nhận',
      'zh': '已确认',
      'ja': '注文確認',
    },
    'orderStatusCancelled': {
      'ko': '주문 취소',
      'en': 'Cancelled',
      'th': 'ยกเลิกแล้ว',
      'vi': 'Đã hủy',
      'zh': '已取消',
      'ja': 'キャンセル',
    },
    'deliveryAccepted': {
      'ko': '배송 접수',
      'en': 'Accepted',
      'th': 'รับจัดส่งแล้ว',
      'vi': 'Đã tiếp nhận',
      'zh': '已受理配送',
      'ja': '配送受付',
    },
    'deliveryPreparing': {
      'ko': '상품 준비중',
      'en': 'Preparing',
      'th': 'กำลังจัดเตรียม',
      'vi': 'Đang chuẩn bị',
      'zh': '准备中',
      'ja': '商品準備中',
    },
    'deliveryInTransit': {
      'ko': '배송중',
      'en': 'In transit',
      'th': 'กำลังจัดส่ง',
      'vi': 'Đang giao',
      'zh': '配送中',
      'ja': '配送中',
    },
    'deliveryDelivered': {
      'ko': '배송 완료',
      'en': 'Delivered',
      'th': 'จัดส่งแล้ว',
      'vi': 'Đã giao',
      'zh': '已送达',
      'ja': '配送完了',
    },
    'orderCompleteTitle': {
      'ko': '주문 완료',
      'en': 'Order complete',
      'th': 'สั่งซื้อสำเร็จ',
      'vi': 'Đặt hàng thành công',
      'zh': '下单成功',
      'ja': '注文完了',
    },
    'bankAccountTitle': {
      'ko': '입금 계좌',
      'en': 'Bank account',
      'th': 'บัญชีโอนเงิน',
      'vi': 'Tài khoản chuyển khoản',
      'zh': '转账账户',
      'ja': '振込口座',
    },
    'depositGuide': {
      'ko': '아래 계좌로 입금해 주시면 확인 후 주문이 진행됩니다.',
      'en': 'Transfer the amount to this account to proceed.',
      'th': 'โอนเงินตามบัญชีนี้เพื่อดำเนินการต่อ',
      'vi': 'Chuyển khoản vào tài khoản này để tiếp tục đơn hàng.',
      'zh': '请向以下账户转账，确认后将继续处理订单。',
      'ja': '下記口座へご入金後、確認でき次第注文を進めます。',
    },
    'bankName': {
      'ko': '은행',
      'en': 'Bank',
      'th': 'ธนาคาร',
      'vi': 'Ngân hàng',
      'zh': '银行',
      'ja': '銀行',
    },
    'accountNumber': {
      'ko': '계좌',
      'en': 'Account',
      'th': 'เลขบัญชี',
      'vi': 'Số tài khoản',
      'zh': '账号',
      'ja': '口座番号',
    },
    'accountHolder': {
      'ko': '예금주',
      'en': 'Holder',
      'th': 'ชื่อบัญชี',
      'vi': 'Chủ tài khoản',
      'zh': '户名',
      'ja': '口座名義',
    },
    'copyAccount': {
      'ko': '복사',
      'en': 'Copy',
      'th': 'คัดลอก',
      'vi': 'Sao chép',
      'zh': '复制',
      'ja': 'コピー',
    },
    'accountCopied': {
      'ko': '계좌번호가 복사되었습니다.',
      'en': 'Account number copied.',
      'th': 'คัดลอกเลขบัญชีแล้ว',
      'vi': 'Đã sao chép số tài khoản.',
      'zh': '已复制账号。',
      'ja': '口座番号をコピーしました。',
    },
    'depositAmount': {
      'ko': '입금 금액',
      'en': 'Amount due',
      'th': 'ยอดที่ต้องโอน',
      'vi': 'Số tiền cần chuyển',
      'zh': '应转金额',
      'ja': 'ご入金金額',
    },
    'continueShopping': {
      'ko': '쇼핑 계속하기',
      'en': 'Continue shopping',
      'th': 'เลือกซื้อต่อ',
      'vi': 'Tiếp tục mua sắm',
      'zh': '继续购物',
      'ja': '買い物を続ける',
    },
    'guestOrderInquiry': {
      'ko': '비회원 주문조회',
      'en': 'Guest order lookup',
      'th': 'ค้นหาคำสั่งซื้อแขก',
      'vi': 'Tra cứu đơn khách',
      'zh': '非会员订单查询',
      'ja': 'ゲスト注文照会',
    },
    'guestOrderInquiryDesc': {
      'ko': '주문번호와 주문 시 입력한 전화번호로 주문 상태를 확인할 수 있습니다.',
      'en': 'Look up your order with the order number and phone number.',
      'th': 'ค้นหาคำสั่งซื้อด้วยหมายเลขคำสั่งซื้อและเบอร์โทร',
      'vi': 'Tra cứu đơn bằng mã đơn và số điện thoại.',
      'zh': '可通过订单号和下单时填写的电话查询订单。',
      'ja': '注文番号とご注文時の電話番号で確認できます。',
    },
    'lookupOrder': {
      'ko': '주문 조회',
      'en': 'Look up',
      'th': 'ค้นหา',
      'vi': 'Tra cứu',
      'zh': '查询',
      'ja': '照会する',
    },
    'lookingUpOrder': {
      'ko': '조회 중...',
      'en': 'Looking up...',
      'th': 'กำลังค้นหา...',
      'vi': 'Đang tra cứu...',
      'zh': '查询中...',
      'ja': '照会中...',
    },
    'guestOrderNotFound': {
      'ko': '일치하는 주문을 찾지 못했습니다. 주문번호와 전화번호를 확인해 주세요.',
      'en': 'No matching order found. Check the order number and phone.',
      'th': 'ไม่พบคำสั่งซื้อ ตรวจสอบหมายเลขและเบอร์โทร',
      'vi': 'Không tìm thấy đơn hàng. Kiểm tra mã đơn và số điện thoại.',
      'zh': '未找到匹配订单，请核对订单号和电话。',
      'ja': '該当する注文が見つかりません。番号をご確認ください。',
    },
    'comingSoon': {
      'ko': '준비 중입니다.',
      'en': 'Coming soon.',
      'th': 'เร็ว ๆ นี้',
      'vi': 'Sắp ra mắt.',
      'zh': '即将推出。',
      'ja': '準備中です。',
    },
  };

  String _s(String key) =>
      _strings[key]?[_locale.languageCode] ?? _strings[key]?['ko'] ?? key;

  // Navigation
  String get navHome => _s('navHome');
  String get navProducts => _s('navProducts');
  String get navCart => _s('navCart');
  String get navWishlist => _s('navWishlist');
  String get navProfile => _s('navProfile');

  // Home
  String get searchProductHint => _s('searchProductHint');
  String get pullToRefresh => _s('pullToRefresh');
  String get retry => _s('retry');

  // Cart
  String get cartTitle => _s('cartTitle');
  String get cartEmpty => _s('cartEmpty');
  String get cartEmptyDesc => _s('cartEmptyDesc');
  String get orderAmount => _s('orderAmount');
  String get placeOrder => _s('placeOrder');

  // Wishlist
  String get wishlistTitle => _s('wishlistTitle');
  String get wishlistEmpty => _s('wishlistEmpty');
  String get wishlistEmptyDesc => _s('wishlistEmptyDesc');

  // Product Detail
  String get productDesc => _s('productDesc');
  String get quantity => _s('quantity');
  String get subtotal => _s('subtotal');
  String get addToCart => _s('addToCart');
  String get buyNow => _s('buyNow');

  // Checkout
  String get checkoutTitle => _s('checkoutTitle');
  String get shippingAddress => _s('shippingAddress');
  String get changeAddress => _s('changeAddress');
  String get paymentMethod => _s('paymentMethod');
  String get bankTransfer => _s('bankTransfer');
  String get orderNoteLabel => _s('orderNoteLabel');
  String get orderNoteHint => _s('orderNoteHint');
  String get paymentAmount => _s('paymentAmount');
  String get productAmount => _s('productAmount');
  String get shippingFee => _s('shippingFee');
  String get free => _s('free');
  String get finalAmount => _s('finalAmount');
  String get payLabel => _s('payLabel');

  // Profile
  String get profileTitle => _s('profileTitle');
  String get signOut => _s('signOut');
  String get addressManage => _s('addressManage');
  String get languageSettings => _s('languageSettings');
  String get selectLanguage => _s('selectLanguage');

  // Address
  String get addAddress => _s('addAddress');
  String get addressNameLabel => _s('addressNameLabel');
  String get address2Label => _s('address2Label');
  String get saveAddress => _s('saveAddress');
  String get defaultAddress => _s('defaultAddress');
  String get setDefaultAddress => _s('setDefaultAddress');
  String get noAddresses => _s('noAddresses');
  String get noAddressesDesc => _s('noAddressesDesc');

  // Auth
  String get signIn => _s('signIn');
  String get signUp => _s('signUp');
  String get emailLabel => _s('emailLabel');
  String get passwordLabel => _s('passwordLabel');
  String get nameLabel => _s('nameLabel');
  String get phoneLabel => _s('phoneLabel');
  String get authRequiredTitle => _s('authRequiredTitle');
  String get authRequiredDesc => _s('authRequiredDesc');
  String get profileGuestDesc => _s('profileGuestDesc');
  String get orderInquiry => _s('orderInquiry');
  String get orderInquiryEmpty => _s('orderInquiryEmpty');
  String get orderInquiryEmptyDesc => _s('orderInquiryEmptyDesc');
  String get orderInquiryAuthDesc => _s('orderInquiryAuthDesc');
  String get orderDetailTitle => _s('orderDetailTitle');
  String get orderNumber => _s('orderNumber');
  String get orderDateLabel => _s('orderDateLabel');
  String get orderItems => _s('orderItems');
  String get recipientInfo => _s('recipientInfo');
  String get noOrderNote => _s('noOrderNote');
  String get orderPlacedTitle => _s('orderPlacedTitle');
  String get orderPlacedDesc => _s('orderPlacedDesc');
  String get orderCompleteTitle => _s('orderCompleteTitle');
  String get bankAccountTitle => _s('bankAccountTitle');
  String get depositGuide => _s('depositGuide');
  String get bankName => _s('bankName');
  String get accountNumber => _s('accountNumber');
  String get accountHolder => _s('accountHolder');
  String get copyAccount => _s('copyAccount');
  String get accountCopied => _s('accountCopied');
  String get depositAmount => _s('depositAmount');
  String get continueShopping => _s('continueShopping');
  String get guestOrderInquiry => _s('guestOrderInquiry');
  String get guestOrderInquiryDesc => _s('guestOrderInquiryDesc');
  String get lookupOrder => _s('lookupOrder');
  String get lookingUpOrder => _s('lookingUpOrder');
  String get guestOrderNotFound => _s('guestOrderNotFound');
  String get comingSoon => _s('comingSoon');

  String orderStatusLabel(OrderStatus status) => switch (status) {
        OrderStatus.placed => _s('orderStatusPlaced'),
        OrderStatus.paymentPending => _s('orderStatusPaymentPending'),
        OrderStatus.confirmed => _s('orderStatusConfirmed'),
        OrderStatus.cancelled => _s('orderStatusCancelled'),
      };

  String deliveryStatusLabel(DeliveryStatus status) => switch (status) {
        DeliveryStatus.accepted => _s('deliveryAccepted'),
        DeliveryStatus.preparing => _s('deliveryPreparing'),
        DeliveryStatus.inTransit => _s('deliveryInTransit'),
        DeliveryStatus.delivered => _s('deliveryDelivered'),
      };

  // Parameterized
  String sortModeLabel(SortMode mode) => switch (mode) {
        SortMode.recommended => _s('sortRecommended'),
        SortMode.latest => _s('sortLatest'),
        SortMode.lowPrice => _s('sortLowPrice'),
        SortMode.highPrice => _s('sortHighPrice'),
      };

  String productCount(int count) => switch (_locale.languageCode) {
        'en' => '$count items',
        'th' => '$count รายการ',
        'vi' => '$count sản phẩm',
        'zh' => '$count 件商品',
        'ja' => '$count 件',
        _ => '상품 $count개',
      };

  String itemQty(int quantity) => switch (_locale.languageCode) {
        'en' => 'Qty $quantity',
        'th' => '$quantity ชิ้น',
        'vi' => 'SL $quantity',
        'zh' => '×$quantity',
        'ja' => '$quantity 個',
        _ => '$quantity개',
      };

  String addedToCart(String name, int qty) => switch (_locale.languageCode) {
        'en' => '$name x$qty added to cart',
        'th' => 'เพิ่ม $name $qty ชิ้นในตะกร้าแล้ว',
        'vi' => 'Đã thêm $name x$qty vào giỏ hàng.',
        'zh' => '已将 $name ×$qty 加入购物车。',
        'ja' => '$name を$qty 個カートに追加しました。',
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

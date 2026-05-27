# Asian Mart Flutter App

Asian Mart 고객용 Flutter 앱입니다. 기존 목업 UI를 제거하고 `AsianMart-Backend`의 실제 API를 기준으로 상품 조회, 로그인/회원가입, 장바구니, 찜, 배송지, 주문 생성 흐름을 연결한 상태입니다.

## 프로젝트 위치

- Flutter 앱: `C:\proj\asian_mart_app`
- 백엔드: `C:\proj\asian_mart\AsianMart-Backend`
- 백엔드 기본 주소: `http://localhost:8080`
- 실제 Android 기기 기본 주소: `http://192.168.0.10:8080`

실제 휴대폰에서 실행할 때는 `localhost`가 PC가 아니라 휴대폰 자신을 가리킵니다. 그래서 Android는 기본적으로 PC의 Wi-Fi IP인 `192.168.0.10`을 사용하도록 되어 있습니다. 네트워크가 바뀌면 실행 시 `API_BASE_URL`을 덮어써야 합니다.

```bash
flutter run --dart-define=API_BASE_URL=http://<PC_IP>:8080
```

## 실행 전 준비

1. 백엔드를 먼저 실행합니다.
2. 휴대폰과 백엔드 PC가 같은 Wi-Fi에 있는지 확인합니다.
3. Windows 방화벽이 `8080` 포트를 막고 있지 않은지 확인합니다.
4. Flutter 의존성을 설치합니다.

```bash
flutter pub get
flutter run
```

Android Studio에서 실행할 때도 같은 원칙입니다. 실제 기기에서 데이터가 안 뜨면 `lib/core/config/api_config.dart`의 Android 기본 IP 또는 `--dart-define=API_BASE_URL=...` 값을 먼저 확인합니다.

## 빌드 설정

Android 최소 SDK는 `23`입니다. `firebase_messaging`가 `minSdk 23` 이상을 요구하므로 낮추면 빌드가 실패합니다.

관련 파일:

- `android/app/build.gradle`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/google-services.json`

빌드 확인:

```bash
flutter analyze lib
flutter build apk --debug
```

현재 Kotlin `1.8.22` 관련 경고가 나올 수 있습니다. 지금 당장 빌드 실패 원인은 아니지만, Flutter 버전을 올릴 때 `android/settings.gradle`의 Kotlin Gradle Plugin 버전도 같이 점검해야 합니다.

## 주요 기능

- 상품 목록 조회
- 상품 검색 및 정렬
- 상품 상세 조회
- 장바구니 조회, 추가, 수량 변경, 선택/해제, 삭제
- 로그인/회원가입
- 찜 목록 조회 및 토글
- 배송지 조회, 추가, 기본 배송지 설정, 삭제
- 주문 생성
- 언어 설정 화면

현재 백엔드에 주문 목록 조회 API가 없기 때문에 주문내역 화면은 활성 기능으로 유지하지 않습니다. 주문내역을 다시 넣으려면 백엔드에 주문 조회 API를 먼저 추가해야 합니다.

## 백엔드 API 연결 구조

API 호출은 `lib/core/network/api_client.dart`에 모여 있습니다. 화면에서 직접 HTTP를 호출하지 않고 `AppController`를 통해 상태를 변경합니다.

주요 흐름:

- `ApiConfig`: API base URL 결정
- `ApiClient`: HTTP 요청/응답 파싱
- `AppController`: 앱 상태, 인증 상태, 장바구니, 찜, 배송지, 주문 처리
- `AppScope`: 화면 트리에서 컨트롤러 접근
- `StorefrontShell`: 하단 탭과 주요 화면 연결

관련 파일:

- `lib/core/config/api_config.dart`
- `lib/core/network/api_client.dart`
- `lib/core/network/api_exception.dart`
- `lib/core/state/app_controller.dart`
- `lib/core/state/app_scope.dart`
- `lib/presentation/shell/storefront_shell.dart`

## 화면 구조

현재 사용 중인 주요 화면은 다음과 같습니다.

- `lib/presentation/home`: 상품 목록, 검색, 정렬
- `lib/presentation/product_detail`: 상품 상세, 장바구니 추가, 바로구매
- `lib/presentation/cart`: 장바구니
- `lib/presentation/wishlist`: 찜
- `lib/presentation/profile`: 내 정보, 배송지
- `lib/presentation/checkout`: 주문 생성
- `lib/presentation/auth`: 로그인/회원가입
- `lib/presentation/settings`: 언어 설정
- `lib/presentation/widgets`: 공통 UI 컴포넌트

`catalog`, `orders` 폴더가 남아 있을 수 있지만 현재 주요 실행 흐름에서는 사용하지 않습니다. 다시 기능을 살릴 때는 백엔드 API 존재 여부를 먼저 확인하고 연결해야 합니다.

## UI 유지보수 규칙

탭 화면의 헤더와 본문 간격은 `lib/presentation/widgets/tab_header.dart`의 `TabLayoutSpacing`을 기준으로 맞춥니다. 장바구니, 찜, 내정보처럼 같은 탭 계열 화면은 각자 숫자를 직접 쓰지 말고 이 값을 재사용합니다.

공통 규칙:

- 탭 상단 헤더는 `TabHeader` 사용
- 탭 본문 가로 여백은 `TabLayoutSpacing.horizontal`
- 탭 본문 상단 여백은 `TabLayoutSpacing.contentTop`
- 탭 본문 하단 여백은 `TabLayoutSpacing.contentBottom`
- 색상, radius, text theme은 `AppTheme` 기준 사용

새 화면을 만들 때는 기존 위젯을 먼저 재사용합니다.

- 상품 이미지: `ProductImage`
- 빈 상태: `EmptyState`
- 수량 변경: `QuantityStepper`
- 탭 헤더: `TabHeader`

## 상태 관리 기준

이 프로젝트는 별도 상태관리 패키지 없이 `ChangeNotifier` 기반의 `AppController`를 사용합니다.

새 기능을 추가할 때 권장 흐름:

1. 백엔드 API 계약을 확인합니다.
2. 필요한 응답 모델을 `lib/domain/entities`에 추가합니다.
3. `ApiClient`에 HTTP 메서드를 추가합니다.
4. `AppController`에 상태와 액션 메서드를 추가합니다.
5. 화면에서는 `AppController` 메서드만 호출합니다.
6. `flutter analyze lib`로 확인합니다.

화면에서 직접 `HttpClient`, `fetch`, `dio` 같은 네트워크 코드를 만들지 않습니다. 네트워크 코드는 `ApiClient`로 모읍니다.

## 백엔드와 맞춰야 하는 부분

현재 앱은 백엔드에 실제로 있는 API만 기준으로 구성되어 있습니다.

사용 중인 사용자 앱 API:

- `GET /api/products`
- `GET /api/products/{id}`
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `POST /api/users/signup`
- `GET /api/users/me`
- `GET /api/cart`
- `POST /api/cart/items`
- `PATCH /api/cart/items/{cartItemId}/quantity`
- `PATCH /api/cart/items/{cartItemId}/selected`
- `DELETE /api/cart/items/{cartItemId}`
- `DELETE /api/cart/items/selected`
- `GET /api/wishlist`
- `POST /api/wishlist/items/{productId}/toggle`
- `GET /api/users/addresses`
- `POST /api/users/addresses`
- `PATCH /api/users/addresses/{addressId}/default`
- `DELETE /api/users/addresses/{addressId}`
- `POST /order/place`

아직 없거나 부족한 API:

- 주문내역 조회
- 주문 상세 조회
- 공개 카테고리 목록 조회
- 공개 상품 이미지 다건 조회
- 리뷰/평점
- 결제 승인/실패 처리
- 관리자 권한 검증이 포함된 백오피스 플로우

위 기능을 UI에 추가하려면 먼저 백엔드 API를 확정해야 합니다. 목업 데이터로 화면만 먼저 만들면 다시 제거하거나 재작업할 가능성이 큽니다.

## 테스트 계정과 시드 데이터

백엔드에 시드 데이터가 들어가 있으면 아래 계정으로 테스트할 수 있습니다.

- 이메일: `demo@asianmart.local`
- 비밀번호: `demo1234`

시드 데이터는 백엔드의 상품, 카테고리, 재고, 이미지, 데모 계정을 넣는 용도입니다. 데이터가 안 보이면 백엔드 DB가 다른 인스턴스를 보고 있는지, 백엔드가 정상 실행 중인지, 앱의 `API_BASE_URL`이 맞는지 확인합니다.

## 자주 나는 문제

### 실제 Android 기기에서 상품이 안 보임

대부분 API 주소 문제입니다. 실제 휴대폰에서는 `localhost:8080`으로 PC 백엔드에 접속할 수 없습니다.

확인 순서:

1. PC와 휴대폰이 같은 Wi-Fi인지 확인합니다.
2. PC의 IP를 확인합니다.
3. 앱 실행 시 `--dart-define=API_BASE_URL=http://<PC_IP>:8080`을 지정합니다.
4. PC 방화벽에서 `8080` inbound가 열려 있는지 확인합니다.

### `firebase_messaging` minSdk 에러

`android/app/build.gradle`의 `minSdkVersion`이 `23` 이상이어야 합니다. `flutter.minSdkVersion`으로 되돌리면 다시 `21`로 들어가 빌드가 실패할 수 있습니다.

### 패키지 업데이트 안내가 많이 나옴

`flutter pub get`, `flutter analyze`, `flutter build` 중에 `newer versions incompatible with dependency constraints` 메시지가 나올 수 있습니다. 이는 실패가 아니라 최신 버전 안내입니다. 기능 변경 중에는 무리하게 major upgrade를 하지 말고, 별도 작업으로 분리해서 처리합니다.

### 레이아웃이 탭마다 다르게 보임

각 탭에서 직접 `EdgeInsets.fromLTRB(...)` 숫자를 새로 쓰지 말고 `TabLayoutSpacing`을 사용합니다. 공통 헤더는 `TabHeader`로 통일합니다.

## 유지보수 체크리스트

기능을 수정하거나 추가한 뒤 최소한 아래를 확인합니다.

```bash
flutter analyze lib
flutter build apk --debug
```

백엔드 DTO나 API 응답이 바뀌면 아래도 같이 확인합니다.

- `ApiClient` 파싱 로직
- `domain/entities` 모델
- `AppController` 상태 갱신
- 화면의 empty/loading/error 상태
- 실제 Android 기기에서 API 연결

## 현재 연동 상태 및 알려진 문제

팀원 인수인계용으로, 지금 앱이 어떤 기능은 되고 어떤 기능은 안 되는지 정리합니다.

### 정상 동작 중인 기능

| 기능 | API | 비고 |
|------|-----|------|
| 상품 목록 조회 | GET /api/products | 전체 일괄 로드 후 클라이언트에서 검색·정렬 |
| 상품 상세 조회 | GET /api/products/{id} | |
| 회원가입 | POST /api/users/signup | |
| 로그인 / 로그아웃 | POST /api/auth/login, /logout | 로그인 후 쿠키 기반 세션 |
| 내 정보 조회 | GET /api/users/me | |
| 장바구니 조회·추가·수량·선택·삭제 | GET/POST/PATCH/DELETE /api/cart/items | 로그인 필수 |
| 찜 목록 조회 및 토글 | GET /api/wishlist, POST /api/wishlist/items/{id}/toggle | 로그인 필수 |
| 배송지 조회·추가·기본 설정·삭제 | GET/POST/PATCH/DELETE /api/users/addresses | 로그인 필수 |

### 백엔드 버그로 현재 동작 안 하는 기능

#### 주문 생성 — `POST /order/place`

주문 생성 요청을 보내면 서버에서 **500 Internal Server Error**가 반환됩니다. 백엔드 코드에 두 가지 버그가 있습니다. 백엔드 담당자가 아래 두 곳을 수정해야 합니다.

**버그 1: `OrderService.java` — 클래스 레벨 `@Transactional(readOnly = true)` 제거 필요**

```java
// 현재 (잘못됨) — 클래스 레벨 readOnly가 placeOrder에도 적용되어 INSERT 불가
@Service
@Transactional(readOnly = true)
public class OrderService {
    public OrderResponse placeOrder(...) { ... }  // DB 쓰기가 필요한데 readOnly라 실패
}

// 수정 방향 — 클래스 레벨 어노테이션 제거 후 읽기 메서드에만 개별 지정
@Service
public class OrderService {
    @Transactional(readOnly = true)
    public OrderResponse getOrder(...) { ... }

    @Transactional
    public OrderResponse placeOrder(...) { ... }
}
```

**버그 2: `OrderPlaceRequest.java` — `toOrder()` 메서드에 `userId`와 `orderDate` 매핑 누락**

```java
// 현재 (잘못됨) — userId, orderDate가 null로 저장됨
public Order toOrder() {
    return Order.builder()
        .totalAmount(this.totalAmount)
        .payAmount(this.payAmount)
        // .userId(...)    ← 없음
        // .orderDate(...) ← 없음
        .build();
}

// 수정 방향
public Order toOrder(Long userId) {
    return Order.builder()
        .userId(userId)
        .orderDate(LocalDateTime.now())
        .totalAmount(this.totalAmount)
        .payAmount(this.payAmount)
        .build();
}
```

백엔드가 수정되기 전까지 앱의 결제/주문 완료 화면은 사용할 수 없습니다.

### API가 없어서 구현하지 못한 기능

아래 기능은 백엔드에 해당 API가 없어서 앱에 구현되어 있지 않습니다. 화면을 추가하려면 백엔드 API를 먼저 만들어야 합니다.

| 기능 | 필요한 API |
|------|-----------|
| 주문 내역 조회 | GET /api/orders 또는 GET /api/users/me/orders |
| 주문 상세 조회 | GET /api/orders/{orderId} |
| 결제 승인/실패 처리 | 결제 PG 연동 API |
| 리뷰 및 평점 | GET/POST /api/products/{id}/reviews |
| 카테고리 목록 조회 | GET /api/categories |

### 앱 설계상 알아둘 점

- **상품 전량 클라이언트 로드**: 현재 `GET /api/products`를 한 번에 전부 받아서 앱 메모리에 저장합니다. 상품이 수백 개를 넘으면 첫 로딩이 느려질 수 있습니다. 백엔드에 페이지네이션(`?page=0&size=20`)이 생기면 `AppController.loadProducts()`와 `HomeTab`에서 무한스크롤로 전환해야 합니다.
- **카테고리 API 없음**: 홈 화면의 카테고리 필터는 서버에서 받아오지 않고 상품 데이터에서 추출해서 표시합니다. 카테고리 API가 생기면 교체해야 합니다.
- **게스트 장바구니**: UI에서는 비로그인 시 장바구니를 사용할 수 없도록 막아 두었습니다. 다만 `AppController` 내부에는 게스트 장바구니 병합 코드(`_mergeGuestCartIntoMemberCart`)가 남아 있습니다. 백엔드에 게스트 세션 API가 생기면 활성화할 수 있습니다.

enum SortMode {
  recommended,
  latest,
  lowPrice,
  highPrice;
}

extension SortModeApi on SortMode {
  /// 백엔드(Spring Data) `sort` 쿼리 파라미터 형식으로 변환한다.
  /// 추천순은 백엔드 기본 정렬을 사용하므로 null을 반환한다.
  String? get apiSort => switch (this) {
        SortMode.recommended => null,
        SortMode.latest => 'createdAt,desc',
        SortMode.lowPrice => 'sellingPrice,asc',
        SortMode.highPrice => 'sellingPrice,desc',
      };
}

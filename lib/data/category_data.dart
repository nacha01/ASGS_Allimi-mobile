class Category {
  // UI에 보여줄 상품의 "category" 속성 값에 대해 mapping 을 위한 클래스
  static final c1 = '음료';
  static final c2 = '과자';
  static final c3 = '아이스크림';
  static final c4 = '커피';
  static final c5 = '생필품';
  static final categoryIndexToStringMap = {
    0: '$c1류',
    1: '$c2류',
    2: '$c3류',
    3: '$c4류',
    4: '$c5류'
  };
  static final categoryStringToIndexMap = {
    '$c1류': 0,
    '$c2류': 1,
    '$c3류': 2,
    '$c4류': 3,
    '$c5류': 4
  };
  static final categoryList = ['$c1류', '$c2류', '$c3류', '$c4류', '$c5류'];
  static final categoryImageNamePrefixMap = {
    '$c1류': 'F',
    '$c2류': 'S',
    '$c3류': 'D',
    '$c4류': 'SS',
    '$c5류': 'H'
  };
}

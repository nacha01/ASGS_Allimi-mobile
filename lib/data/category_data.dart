class Category {
  // UI에 보여줄 상품의 "category" 속성 값에 대해 mapping 을 위한 클래스
  static final c1 = '음식';
  static final c2 = '간식';
  static final c3 = '음료';
  static final c4 = '문구';
  static final c5 = '핸드메이드';
  static final categoryIndexToStringMap = {
    0: '$c1',
    1: '$c2',
    2: '$c3',
    3: '$c4',
    4: '$c5'
  };
  static final categoryStringToIndexMap = {
    '$c1': 0,
    '$c2': 1,
    '$c3': 2,
    '$c4': 3,
    '$c5': 4
  };
  static final categoryList = ['$c1', '$c2', '$c3', '$c4', '$c5'];
  static final categoryImageNamePrefixMap = {
    '$c1': 'F',
    '$c2': 'S',
    '$c3': 'D',
    '$c4': 'SS',
    '$c5': 'H'
  };
}

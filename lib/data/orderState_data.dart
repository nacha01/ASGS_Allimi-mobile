import 'package:flutter/material.dart';

class OrderState {
  static final orderStateList = [
    '미결제 및 미수령',
    '결제완료 및 미수령',
    '주문 처리 중',
    '결제완료 및 수령완료',
    '결제취소 및 주문취소'
  ];
  static final colorState = [
    Colors.red,
    Colors.orangeAccent,
    Colors.lightBlue,
    Colors.green,
    Colors.grey
  ];
}

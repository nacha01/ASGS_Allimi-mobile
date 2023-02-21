class PaymentCancelResponse {
  String resultCode;
  String resultMsg;
  int cancelAmount;
  String tid;

  PaymentCancelResponse(
      this.resultCode, this.resultMsg, this.cancelAmount, this.tid);

  PaymentCancelResponse.fromJson(Map<String, dynamic> json)
      : resultCode = json['ResultCode'],
        resultMsg = json['ResultMsg'],
        cancelAmount = int.parse(json['CancelAmt']),
        tid = json['TID'];
}

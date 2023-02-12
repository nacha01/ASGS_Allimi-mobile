class NotificationPayload {
  static bool isTap = false; // notification 클릭 여부
  static String? payload; // 클릭 시 이동할 location payload

  static void setPayload(String? payload) {
    NotificationPayload.payload = payload;
  }
}

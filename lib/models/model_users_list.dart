class ModelUsersInfo {
  List<String>? fcmTokens;
  String? userName;
  String? userID;

  ModelUsersInfo({this.fcmTokens, this.userName, this.userID});

  ModelUsersInfo.fromJson(Map<String, dynamic> json) {
    fcmTokens = fcmTokens != null ?  json['fcm_tokens'].cast<String>() : [];
    userName = json['user_name'];
    userID = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fcm_tokens'] = fcmTokens;
    data['user_name'] = userName;
    data['user_id'] = userID;
    return data;
  }
}

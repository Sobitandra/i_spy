class ModelGameChat {
  String? image;
  int? time;
  String? type;
  String? word;
  String? message;
  String? senderId;

  ModelGameChat({this.image, this.time, this.type, this.word, this.senderId, this.message});

  ModelGameChat.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    time = json['time'];
    type = json['type'];
    word = json['word'];
    message = json['message'];
    senderId = json['sender_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['time'] = time;
    data['type'] = type;
    data['word'] = word;
    data['message'] = message;
    data['sender_id'] = senderId;
    return data;
  }
}

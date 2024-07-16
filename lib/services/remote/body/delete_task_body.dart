class DeleteTaskBody {
  List<String>? ids;
  String? type;

  DeleteTaskBody();

  factory DeleteTaskBody.fromJson(Map<String, dynamic> json) => DeleteTaskBody() //truyen map vao de lay dc object,  cai nay lay ve
    ..ids = json['ids'] as List<String>? //truy cap key de lay value
    ..type = json['type'] as String?;

  Map<String, dynamic> toJson() { //cai nay day len
  //bien object thanh map
    return {
      if (ids != null) 'ids': ids,
      if (type != null) 'type': type,
    };
  }
}

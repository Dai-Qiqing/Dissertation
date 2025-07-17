class Outfit {
  final dynamic id;
  final dynamic name;
  final dynamic description;
  final dynamic views;
  final dynamic picture;
  final dynamic category;
  final dynamic favorite;
  final DateTime? createdAt;
  final DateTime? updateAt;

  Outfit({
    this.id,
    this.name,
    this.description,
    this.views,
    this.picture,
    this.category,
    this.favorite,
    this.createdAt,
    this.updateAt,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      views: json['views'],
      picture: json['picture'],
      category: json['category'],
      favorite: json['favorite'],
      createdAt: DateTime.parse(json['created_at']),
      updateAt: DateTime.parse(json['update_at']),
    );
  }
}

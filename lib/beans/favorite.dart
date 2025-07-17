class Favorite {
  final dynamic id;
  final dynamic name;
  final dynamic description;
  final dynamic views;
  final dynamic picture;
  final dynamic category;
  final DateTime? updateAt;

  Favorite({
    this.id,
    this.name,
    this.description,
    this.views,
    this.picture,
    this.category,
    this.updateAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      views: json['views'],
      picture: json['picture'],
      category: json['category'],
      updateAt: DateTime.parse(json['update_at']),
    );
  }
}

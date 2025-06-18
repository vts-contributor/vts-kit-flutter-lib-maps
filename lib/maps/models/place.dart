class Place {
  final String id;

  Place(this.id);

  Map<String, dynamic> toJson() {
    return {
      'place_id': id,
    };
  }
}

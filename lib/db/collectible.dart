class Collectible {
  final int id;
  final String title;
  final int mint;
  final String? description;
  final String? image;

  const Collectible({
    required this.id,
    required this.title,
    required this.mint,
    this.description,
    this.image,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'mint': mint,
      'description': description,
      'image': image,
    };
  }

  @override
  String toString() {
    return 'Collectible{id: $id, title: $title, mint: $mint, description: $description, image: $image}';
  }
}

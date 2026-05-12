class ProductModel {
  final int id;
  final String name;
  final double price;
  final String description;
  final String? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      description: json['description'],
      createdAt: json['created_at'],
    );
  }

  // Format harga ke Rupiah
  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }
}
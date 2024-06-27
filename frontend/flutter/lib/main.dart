import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductSearchScreen(),
    );
  }
}

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = false;

  Future<void> _searchProducts(String query) async {
    setState(() {
      _isLoading = true;
    });

    print('User query: $query'); // Log the query to ensure it's being captured

    final response = await http.post(
      Uri.parse('https://77d2-103-134-7-130.ngrok-free.app/query'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'query': query,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> productList = jsonDecode(response.body);
      setState(() {
        _products =
            productList.map((product) => Product.fromJson(product)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchProducts(_controller.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading ? _buildShimmer() : _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 350,
          child: Card(
            elevation: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  height: 340,
                  color: Colors.grey[300],
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 30,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 20,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 15,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 350,
            child: Card(
              elevation: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 340,
                    width: 200,
                    child: Image.asset(
                      'assets/images/${product.id}.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.displayNames,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.descriptions,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Average Rating: ${product.averageRatings}',
                              ),
                              Text(
                                'Number of Ratings: ${product.numberOfRatings}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Product {
  final int id;
  final String displayNames;
  final String masterCategories;
  final String subCategories;
  final String articleTypes;
  final String baseColours;
  final String seasons;
  final int years;
  final String usages;
  final String descriptions;
  final double averageRatings;
  final int numberOfRatings;
  final String imagePath;

  Product({
    required this.id,
    required this.displayNames,
    required this.masterCategories,
    required this.subCategories,
    required this.articleTypes,
    required this.baseColours,
    required this.seasons,
    required this.years,
    required this.usages,
    required this.descriptions,
    required this.averageRatings,
    required this.numberOfRatings,
    required this.imagePath,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      displayNames: json['displayNames'],
      masterCategories: json['masterCategories'],
      subCategories: json['subCategories'],
      articleTypes: json['articleTypes'],
      baseColours: json['baseColours'],
      seasons: json['seasons'],
      years: json['years'],
      usages: json['usages'],
      descriptions: json['descriptions'],
      averageRatings: json['averageRatings'].toDouble(),
      numberOfRatings: json['numberOfRatings'],
      imagePath: json['imagePath'],
    );
  }
}

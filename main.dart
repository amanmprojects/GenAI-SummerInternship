import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductSearchScreen(),
    );
  }
}

class ProductSearchScreen extends StatefulWidget {
  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  TextEditingController _controller = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = false;

  Future<void> _searchProducts(String query) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
<<<<<<< HEAD
      Uri.parse('http://localhost:8888/query'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(<String, String>{
=======
      Uri.parse('http://your-fastapi-url/query'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
>>>>>>> 1c28f23552ae65c51670d18438a9c5b2e4023bb5
        'query': query,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> productList = jsonDecode(response.body);
      setState(() {
<<<<<<< HEAD
        _products =
            productList.map((product) => Product.fromJson(product)).toList();
=======
        _products = productList.map((product) => Product.fromJson(product)).toList();
>>>>>>> 1c28f23552ae65c51670d18438a9c5b2e4023bb5
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
        title: Text('Product Search'),
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
                  icon: Icon(Icons.search),
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
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListTile(
          leading: CircleAvatar(),
          title: Container(
            width: double.infinity,
            height: 10.0,
            color: Colors.white,
          ),
          subtitle: Container(
            width: double.infinity,
            height: 10.0,
            color: Colors.white,
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
        return ListTile(
          leading: Image.network(product.imagePath),
          title: Text(product.displayNames),
          subtitle: Text(product.descriptions),
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

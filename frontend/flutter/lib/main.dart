import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
// import 'dart:io';

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
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  List<String> _searchHistory = [];
  bool _showDropdown = false;
  bool _showSortOptions = false;
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  void _loadSearchHistory() {
    _searchHistory = [];
  }

  void _saveSearchHistory(String query) {
    setState(() {
      if (!_searchHistory.contains(query)) {
        if (_searchHistory.length >= 5) {
          _searchHistory.removeAt(0);
        }
        _searchHistory.add(query);
      }
    });
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
  }

  Future<void> _searchProducts(String query) async {
    setState(() {
      _isLoading = true;
      _saveSearchHistory(query);
      _showSortOptions = true;
    });

    final response = await http.post(
      Uri.parse('https://eab6-103-178-128-87.ngrok-free.app/text_search'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(<String, String>{
        'query': query,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> productList = jsonDecode(response.body);
      setState(() {
        _filteredProducts =
            productList.map((product) => Product.fromJson(product)).toList();
        _isLoading = false;
        _showDropdown = false;
      });
      _scrollToTop();
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load products');
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sortProducts(String criteria) {
    setState(() {
      if (criteria == 'Low to High') {
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (criteria == 'High to Low') {
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
      } else if (criteria == 'Rating') {
        _filteredProducts
            .sort((a, b) => b.averageRatings.compareTo(a.averageRatings));
      } else if (criteria == 'Number of People Rated') {
        _filteredProducts
            .sort((a, b) => b.numberOfRatings.compareTo(a.numberOfRatings));
      }
    });
  }

  Future<void> _uploadImage() async {
    final XFile? image = await showDialog<XFile>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose image source'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context,
                    await _picker.pickImage(source: ImageSource.camera));
              },
              child: const Text('Take a photo'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context,
                    await _picker.pickImage(source: ImageSource.gallery));
              },
              child: const Text('Choose from gallery'),
            ),
          ],
        );
      },
    );

    if (image == null) return;

    setState(() {
      _isLoading = true;
      _showSortOptions = true;
    });

    final url =
        Uri.parse('https://eab6-103-178-128-87.ngrok-free.app/image-search/');
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        List<dynamic> productList = jsonDecode(response.body);
        setState(() {
          _filteredProducts =
              productList.map((product) => Product.fromJson(product)).toList();
          _isLoading = false;
        });
        _scrollToTop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image search completed')),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process image search')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image search: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchField(),
            if (_showDropdown && _searchHistory.isNotEmpty)
              _buildSearchHistory(),
            if (_showSortOptions) _buildSortOptions(),
            Expanded(
              child: _isLoading ? _buildShimmer() : _buildProductList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search for products...',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _searchProducts(_controller.text);
                },
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _uploadImage,
              ),
            ],
          ),
        ),
        onTap: () {
          setState(() {
            _showDropdown = true;
          });
        },
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_searchHistory[index]),
                onTap: () {
                  _controller.text = _searchHistory[index];
                  _searchProducts(_searchHistory[index]);
                },
              );
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _clearSearchHistory,
              child: const Text('Clear History'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return DropdownButton<String>(
      hint: const Text('Sort by'),
      items: <String>[
        'Low to High',
        'High to Low',
        'Rating',
        'Number of People Rated'
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        _sortProducts(newValue!);
      },
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 10,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 350,
          width: 600,
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
    return _filteredProducts.isEmpty && !_isLoading
        ? const Center(child: Text('No products found.'))
        : ListView.builder(
            controller: _scrollController,
            itemCount:
                _filteredProducts.isEmpty ? 10 : _filteredProducts.length,
            itemBuilder: (context, index) {
              if (_filteredProducts.isEmpty && _isLoading) {
                return _buildShimmer();
              }
              final product = _filteredProducts[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 350,
                  child: Card(
                    elevation: 3,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 130,
                          height: 340,
                          color: Colors.grey[300],
                          child: Image.network(
                            'https://eab6-103-178-128-87.ngrok-free.app/images/${product.id}',
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
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.descriptions,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(children: [
                                  RatingBarIndicator(
                                    rating: product.averageRatings,
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    direction: Axis.horizontal,
                                  ),
                                ]),
                                const SizedBox(height: 5),
                                Text(
                                  '(${product.numberOfRatings})',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Price: ₹${product.price}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                  ),
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
  final String descriptions;
  final double averageRatings;
  final int numberOfRatings;
  final double price;

  Product({
    required this.id,
    required this.displayNames,
    required this.descriptions,
    required this.averageRatings,
    required this.numberOfRatings,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String priceString = json['price'].toString();
    String numericPriceString = priceString.replaceAll(RegExp(r'[^\d.]'), '');
    double price = double.tryParse(numericPriceString) ?? 0.0;

    return Product(
      id: json['productId'],
      displayNames: json['productDisplayName'],
      descriptions: json['description'],
      averageRatings: json['averageRating'].toDouble(),
      numberOfRatings: json['numberOfRatings'],
      price: price,
    );
  }
}

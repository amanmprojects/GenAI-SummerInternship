import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isShimmerVisible = false;
  bool _isLoadingData = false;
  bool _showDropdown = false;

  final List<Map<String, dynamic>> _dataList = [
    {
      'image': 'https://m.media-amazon.com/images/I/71I-cik1CyL._AC_SY550_.jpg',
      'title': 'Title 1',
      'description': 'Description 1',
      'prize': '₹100',
      'rating': 3.25,
      'numRatings': 100,
    },
    {
      'image': 'https://m.media-amazon.com/images/I/61o9trA+GEL._AC_SX425_.jpg',
      'title': 'Title 2',
      'description': 'Description 2',
      'prize': '₹200',
      'rating': 4.2,
      'numRatings': 80,
    },
    {
      'image': 'https://m.media-amazon.com/images/I/61avoAvNiAL._AC_SY550_.jpg',
      'title': 'Title 3',
      'description': 'Description 3',
      'prize': '₹150',
      'rating': 4.8,
      'numRatings': 120,
    },
    {
      'image': 'https://via.placeholder.com/200',
      'title': 'Title 4',
      'description': 'Description 4',
      'prize': '₹180',
      'rating': 4.4,
      'numRatings': 95,
    },
    {
      'image': 'https://via.placeholder.com/200',
      'title': 'Title 5',
      'description': 'Description 5',
      'prize': '₹250',
      'rating': 4.7,
      'numRatings': 110,
    },
    {
      'image': 'https://via.placeholder.com/200',
      'title': 'Title 6',
      'description': 'Description 6',
      'prize': '₹300',
      'rating': 4.6,
      'numRatings': 105,
    },
  ];

  String _selectedSortOption = 'All';

  Future<void> _sendRequest() async {
    setState(() {
      _isShimmerVisible = true;
      _isLoadingData = false;
      _showDropdown = true;
    });
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isLoadingData = true;
      });
      _loadData();
    });


    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/process_query'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': _controller.text}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _response = responseData['modified_query'];
      });
    } else {
      setState(() {
        _response = 'Error: ${response.reasonPhrase}';
      });
    }
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 20000000000));
    setState(() {
      _isShimmerVisible = false;
    });
  }

  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    double fraction = rating - fullStars;
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, size: 16, color: Colors.amber));
    }
    if (fraction > 0) {
      stars.add(const Icon(Icons.star_half, size: 16, color: Colors.amber));
    }
    for (int i = stars.length; i < 5; i++) {
      stars.add(const Icon(Icons.star_border, size: 16, color: Colors.grey));
    }
    return Row(children: stars);
  }

  void _sortData(String sortType) {
    setState(() {
      _selectedSortOption = sortType;
      switch (sortType) {
        case 'Price Low to High':
          _dataList.sort((a, b) => a['prize'].compareTo(b['prize']));
          break;
        case 'Price High to Low':
          _dataList.sort((a, b) => b['prize'].compareTo(a['prize']));
          break;
        case 'Rating':
          _dataList.sort((a, b) => b['rating'].compareTo(a['rating']));
          break;
        case 'All':
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cymbal Fashion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'What can we help you find?',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _sendRequest,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_response.isNotEmpty)
                Text(
                  _response,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              if (_showDropdown)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: _selectedSortOption,
                    onChanged: (String? newValue) {
                      _sortData(newValue!);
                    },
                    items: <String>['All', 'Price Low to High', 'Price High to Low', 'Rating']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              _isShimmerVisible
                  ? SizedBox(
                      width: 400,
                      height: 2000,
                      child: ListView.builder(
                        itemCount: _dataList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 300,
                              width: 200,
                              child: Card(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: _isLoadingData
                                          ? Image.network(
                                              _dataList[index]['image'],
                                              width: 200,
                                              height: 300,
                                              fit: BoxFit.cover,
                                            )
                                          : Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                width: 200,
                                                height: 300,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _isLoadingData
                                                ? Text(
                                                    _dataList[index]['title'],
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  )
                                                : Shimmer.fromColors(
                                                    baseColor: Colors.grey[300]!,
                                                    highlightColor: Colors.grey[100]!,
                                                    child: Container(
                                                      height: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                            const SizedBox(height: 5),
                                            _isLoadingData
                                                ? Text(
                                                    _dataList[index]['description'],
                                                    style: const TextStyle(fontSize: 16),
                                                  )
                                                : Shimmer.fromColors(
                                                    baseColor: Colors.grey[300]!,
                                                    highlightColor: Colors.grey[100]!,
                                                    child: Container(
                                                      height: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                            const SizedBox(height: 5),
                                            _isLoadingData
                                                ? Row(
                                                    children: [
                                                      _buildStarRating(_dataList[index]['rating']),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        '(${_dataList[index]['numRatings']})',
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                    ],
                                                  )
                                                : Shimmer.fromColors(
                                                    baseColor: Colors.grey[300]!,
                                                    highlightColor: Colors.grey[100]!,
                                                    child: Container(
                                                      height: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                            _isLoadingData
                                                ? Text(
                                                    'Prize: ${_dataList[index]['prize']}',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontStyle: FontStyle.italic,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                : Shimmer.fromColors(
                                                    baseColor: Colors.grey[300]!,
                                                    highlightColor: Colors.grey[100]!,
                                                    child: Container(
                                                      height: 20,
                                                      color: Colors.white,
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
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

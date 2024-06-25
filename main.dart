import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';

  Future<void> _sendRequest() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cymbal Fashion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'What can we help you find?',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _sendRequest,
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_response.isNotEmpty)
              Text(
                _response,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}

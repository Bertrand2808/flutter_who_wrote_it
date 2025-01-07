import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const BookSearchApp());
}
class BookSearchApp extends StatelessWidget {
  const BookSearchApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qui l\'a écrit ?',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BookSearchScreen(),
    );
  }
}
class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({Key? key}) : super(key: key);
  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}
class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String title = '';
  String author = '';
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Qui l\'a écrit ?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Entrez le titre du livre :'),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Titre du livre',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchBook,
              child: const Text('Rechercher'),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text('Titre : $title', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Auteur : $author', style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }

  void _searchBook() async {
    FocusScope.of(context).unfocus();
    final query = _controller.text;
    final url = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=$query');
    setState(() {
      _isLoading = true;
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'];
      if (items != null && items.isNotEmpty) {
        setState(() {
          title = items[0]['volumeInfo']['title'] ?? 'Titre non trouvé';
          author = items[0]['volumeInfo']['authors']?.join(', ') ?? 'Auteur non trouvé';
        });
      } else {
        setState(() {
          title = 'Aucun résultat trouvé';
          author = '';
        });
      }
    } else {
      setState(() {
        title = 'Erreur de requête';
        author = '';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

}
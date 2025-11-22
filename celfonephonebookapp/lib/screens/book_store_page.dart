import 'package:flutter/material.dart';

class BookStorePage extends StatelessWidget {
  const BookStorePage({super.key});

  final List<Map<String, String>> books = const [
    {
      "title": "The Great Gatsby",
      "author": "F. Scott Fitzgerald",
      "desc":
          "A classic American novel of the Jazz Age, wealth, and the American Dream.",
      "image":
          "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=600",
    },
    {
      "title": "1984",
      "author": "George Orwell",
      "desc": "A dystopian social science fiction novel and cautionary tale.",
      "image":
          "https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=600",
    },
    {
      "title": "To Kill a Mockingbird",
      "author": "Harper Lee",
      "desc":
          "A novel about racial injustice and moral growth in the American South.",
      "image":
          "https://images.unsplash.com/photo-1544716278-ca5e3f3e49c8?w=600",
    },
    {
      "title": "Pride and Prejudice",
      "author": "Jane Austen",
      "desc": "A romantic novel of manners that critiques marriage and class.",
      "image":
          "https://images.unsplash.com/photo-1589820296156-2454a6a1b6d1?w=600",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Book Store"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Directories"),
            const SizedBox(height: 12),
            _buildBookCarousel(context, books),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildBookCarousel(
    BuildContext context,
    List<Map<String, String>> books,
  ) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _buildBookCard(context, book, index, books);
        },
      ),
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    Map<String, String> book,
    int index,
    List<Map<String, String>> allBooks,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                BookDetailPage(initialIndex: index, books: allBooks),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'book-$index',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  book["image"]!,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book["title"]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book["author"]!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// BOOK DETAIL PAGE - SCROLL TO CHANGE BOOK + LIVE UPDATE
// ─────────────────────────────────────────────────────────────────────
class BookDetailPage extends StatefulWidget {
  final int initialIndex;
  final List<Map<String, String>> books;

  const BookDetailPage({
    super.key,
    required this.initialIndex,
    required this.books,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late PageController _pageController;
  late int _currentIndex;

  final List<Color> bgColors = const [
    Color(0xFFFFA726), // Orange
    Color(0xFF42A5F5), // Blue
    Color(0xFF66BB6A), // Green
    Color(0xFFAB47BC), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.8,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = bgColors[_currentIndex % bgColors.length];
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // === TOP: Back + Title ===
          Container(
            padding: EdgeInsets.only(
              top: topPadding + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.books[_currentIndex]["title"]!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // === HORIZONTAL BOOK CAROUSEL ===
          SizedBox(
            height: 280,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.books.length,
              itemBuilder: (context, index) {
                final isActive = index == _currentIndex;
                return AnimatedScale(
                  scale: isActive ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 300),
                  child: Hero(
                    tag: 'book-$index',
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          widget.books[index]["image"]!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.book, size: 80),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // === WHITE CURVED BOTTOM (LIVE UPDATE) ===
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.books[_currentIndex]["title"]!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "by ${widget.books[_currentIndex]["author"]}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.books[_currentIndex]["desc"]!,
                        style: const TextStyle(fontSize: 16, height: 1.7),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Read Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Opening book reader..."),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bgColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        "Read Now",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

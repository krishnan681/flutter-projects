import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageCarouselSection extends StatelessWidget {
  const ImageCarouselSection({super.key});

  // Placeholder images (replace with Supabase URLs later)
  final List<String> _panoramicImages = const [
    'https://picsum.photos/800/300?random=1',
    'https://picsum.photos/800/300?random=2',
    'https://picsum.photos/800/300?random=3',
    'https://picsum.photos/800/300?random=4',
  ];

  final List<String> _verticalImages = const [
    'https://picsum.photos/300/500?random=5',
    'https://picsum.photos/300/500?random=6',
    'https://picsum.photos/300/500?random=7',
    'https://picsum.photos/300/500?random=8',
  ];

  final List<String> _horizontalImages = const [
    'https://picsum.photos/500/300?random=9',
    'https://picsum.photos/500/300?random=10',
    'https://picsum.photos/500/300?random=11',
    'https://picsum.photos/500/300?random=12',
  ];

  final List<String> _squareImages = const [
    'https://picsum.photos/400/400?random=13',
    'https://picsum.photos/400/400?random=14',
    'https://picsum.photos/400/400?random=15',
    'https://picsum.photos/400/400?random=16',
    'https://picsum.photos/400/400?random=17',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPanelWithCarousel(
          title: "Panoramic Images",
          images: _panoramicImages,
          height: 180,
          viewportFraction: 0.9,
          aspectRatio: 2.7,
        ),
        const SizedBox(height: 24),

        _buildPanelWithCarousel(
          title: "Vertical Images",
          images: _verticalImages,
          height: 220,
          viewportFraction: 0.45,
          aspectRatio: 0.6,
        ),
        const SizedBox(height: 24),

        _buildPanelWithCarousel(
          title: "Horizontal Images",
          images: _horizontalImages,
          height: 160,
          viewportFraction: 0.7,
          aspectRatio: 1.67,
        ),
        const SizedBox(height: 24),

        _buildPanelWithCarousel(
          title: "Square Images",
          images: _squareImages,
          height: 180,
          viewportFraction: 0.5,
          aspectRatio: 1.0,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPanelWithCarousel({
    required String title,
    required List<String> images,
    required double height,
    required double viewportFraction,
    required double aspectRatio,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Panel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Carousel
        SizedBox(
          height: height,
          child: CarouselSlider.builder(
            itemCount: images.length,
            itemBuilder: (context, index, _) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: height,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              viewportFraction: viewportFraction,
              aspectRatio: aspectRatio,
              enlargeCenterPage: true,
              autoPlayCurve: Curves.easeInOut,
              enableInfiniteScroll: images.length > 1,
            ),
          ),
        ),
      ],
    );
  }
}

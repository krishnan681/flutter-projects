// import 'package:celfonephonebookapp/screens/homepage_shell.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// /// Data model for each onboarding screen
// class OnboardingContent {
//   final List<InlineSpan> subtitleSpans;
//   OnboardingContent({required this.subtitleSpans});
// }

// final List<OnboardingContent> contentsList = [
//   // 1️⃣ First Slide
//   OnboardingContent(
//     subtitleSpans: [
//       const TextSpan(
//         text: 'Multi Brand\nMobile Directory.\n',
//         style: TextStyle(fontSize: 22, color: Colors.black87, height: 1.5),
//       ),
//       const TextSpan(
//         text: 'Connects for Growth',
//         style: TextStyle(
//           fontSize: 22,
//           fontWeight: FontWeight.bold,
//           color: Colors.black87,
//           height: 1.5,
//         ),
//       ),
//     ],
//   ),
//   // 2️⃣ Second Slide
//   OnboardingContent(
//     subtitleSpans: [
//       const TextSpan(
//         text: 'For Targetted\n',
//         style: TextStyle(fontSize: 22, color: Colors.black87, height: 1.5),
//       ),
//       const TextSpan(
//         text: 'Digital Marketing\n',
//         style: TextStyle(
//           fontSize: 22,
//           fontWeight: FontWeight.bold,
//           color: Colors.black87,
//           height: 1.5,
//         ),
//       ),
//       const TextSpan(
//         text: '* Nearby Promotion\n* Citywide Promotion\n* Favorite Promotion',
//         style: TextStyle(fontSize: 22, color: Colors.black87, height: 1.5),
//       ),
//     ],
//   ),
//   // 3️⃣ Third Slide
//   OnboardingContent(
//     subtitleSpans: [
//       const TextSpan(
//         text:
//             'Your Identity in City\n* Priority Listing\n* Bold Listing\nBe Visible, when searched',
//         style: TextStyle(fontSize: 22, color: Colors.black87, height: 1.5),
//       ),
//     ],
//   ),
// ];

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   bool _termsAccepted = false; // ✅ track checkbox

//   void _onPageChanged(int index) => setState(() => _currentPage = index);

//   Future<void> _navigateToNext() async {
//     final prefs = await SharedPreferences.getInstance();
//     // save flag so onboarding won’t show again
//     await prefs.setBool('showOnboarding', false);
//     if (!mounted) return;
//     Navigator.of(
//       context,
//     ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePageShell()));
//   }

//   /// Telco logo widget (no text, slightly bigger)
//   Widget _buildTelcoLogo(String asset) {
//     return Image.asset(asset, height: 60, width: 60, fit: BoxFit.contain);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLastPage = _currentPage == contentsList.length - 1;

//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Skip button
//             Align(
//               alignment: Alignment.centerRight,
//               child: isLastPage
//                   ? const SizedBox(height: 48)
//                   : TextButton(
//                       onPressed: _navigateToNext,
//                       child: const Text('SKIP'),
//                     ),
//             ),

//             // PageView
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: contentsList.length,
//                 onPageChanged: _onPageChanged,
//                 itemBuilder: (_, i) {
//                   final item = contentsList[i];
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 30.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           'assets/images/companylogo.png',
//                           height: 100,
//                         ),
//                         const SizedBox(height: 20),

//                         // Extra heading only on 3rd slide
//                         if (i == 2)
//                           const Padding(
//                             padding: EdgeInsets.only(bottom: 20),
//                             child: Text(
//                               'Celfon5G+ PHONE BOOK',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ),

//                         // RichText subtitle
//                         RichText(
//                           textAlign: TextAlign.center,
//                           text: TextSpan(children: item.subtitleSpans),
//                         ),

//                         // Telco logos only on 1st slide
//                         if (i == 0) ...[
//                           const SizedBox(height: 40),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               _buildTelcoLogo('assets/images/BSNL.png'),
//                               _buildTelcoLogo('assets/images/airtel.png'),
//                               _buildTelcoLogo('assets/images/jio.png'),
//                               _buildTelcoLogo('assets/images/vi.png'),
//                             ],
//                           ),
//                         ],

//                         // ✅ Checkbox only on 3rd slide
//                         if (i == 2) ...[
//                           const SizedBox(height: 30),
//                           CheckboxListTile(
//                             value: _termsAccepted,
//                             onChanged: (val) {
//                               setState(() => _termsAccepted = val ?? false);
//                             },
//                             title: const Text(
//                               'Accept terms and conditions',
//                               style: TextStyle(fontSize: 18),
//                             ),
//                             controlAffinity: ListTileControlAffinity.leading,
//                           ),
//                         ],
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Dots + Next/Get Started
//             Padding(
//               padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Page indicator
//                   Row(
//                     children: List.generate(
//                       contentsList.length,
//                       (index) => AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         height: 10,
//                         width: _currentPage == index ? 25 : 10,
//                         margin: const EdgeInsets.only(right: 5),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           color: _currentPage == index
//                               ? Theme.of(context).colorScheme.primary
//                               : Colors.grey.shade300,
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Next / Get Started
//                   ElevatedButton(
//                     onPressed: isLastPage
//                         ? (_termsAccepted ? _navigateToNext : null)
//                         : () {
//                             _pageController.nextPage(
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeIn,
//                             );
//                           },
//                     child: Text(
//                       isLastPage ? 'Get Started' : 'Next',
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// lib/screens/onboarding_screen.dart
import 'package:celfonephonebookapp/screens/homepage_shell.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _acceptedTerms = false;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Celfon5G+ Phone Book',
      'icon': 'phone',
      'features': [
        {
          'icon': Icons.search,
          'text':
              'Acts as a Mobile Phone Directory to find numbers of firms or individuals across India and communicate via Call, Text, Email or WhatsApp.',
        },
        {
          'icon': Icons.campaign,
          'text':
              'Works as a Digital Marketing Assistant for small businessmen and professionals to send targeted short messages for business promotion.',
        },
      ],
    },
    {
      'title': 'Data Bank & MSME Benefits',
      'icon': 'bar_chart',
      'features': [
        {
          'icon': Icons.cloud,
          'text':
              'Massive Data Bank of mobile users across India including BSNL, Airtel, Jio, Vi etc., with full 5G communication details.',
        },
        {
          'icon': Icons.storefront,
          'text':
              'Ideal for MSMEs & small businesses to run neighbourhood promotions within a 1–3 km radius and increase walk-in customers.',
        },
        {
          'icon': Icons.message,
          'text':
              'Send frequent, low-cost SMS messages to build your brand and attract new prospects.',
        },
      ],
    },
    {
      'title': 'Messaging & Category Promotions',
      'icon': 'mail',
      'features': [
        {
          'icon': Icons.language,
          'text':
              'Send messages in English, Tamil, Hindi or any Indian language to one, many or all listed users.',
        },
        {
          'icon': Icons.category,
          'text':
              'Category-wise promotions: target businesses or services citywide by product or keyword – perfect for B2B campaigns.',
        },
        {
          'icon': Icons.group,
          'text':
              'Use My List groups (Buyers, Sellers, Family & Friends, Favourites) to organise prospects and message selected groups.',
        },
        {
          'icon': Icons.remove_circle_outline,
          'text':
              'Easy Opt-Out: users can remove their profile from the database anytime.',
        },
      ],
    },
    {'title': 'Terms & Conditions', 'icon': 'check_circle', 'features': []},
  ];

  List<Color> _getGradientColors() {
    switch (_currentPage) {
      case 0:
        return [const Color(0xFF011E37), const Color(0xFF4286f4)];
      case 1:
        return [const Color(0xFF033311), const Color(0xFF3CA55C)];
      case 2:
        return [const Color(0xFF470428), const Color(0xFFD76D77)];
      case 3:
        return [const Color(0xFF2E1B02), const Color(0xFFf4a261)];
      default:
        return [Colors.blue, Colors.green];
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
    if (!mounted) return;

    // No const – HomePageShell is not a const constructor
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => HomePageShell()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getGradientColors(),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip ────────────────────────────────────────
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              // ── PageView ─────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) {
                    if (i == _pages.length - 1) return _buildTermsPage();
                    return _buildFeaturePage(i);
                  },
                ),
              ),

              // ── Dots ────────────────────────────────────────
              _buildDots(),
              const SizedBox(height: 20),

              // ── Buttons ─────────────────────────────────────
              _buildButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // Feature page (icons + telco logos on first slide)
  // ────────────────────────────────────────────────────────
  Widget _buildFeaturePage(int index) {
    final page = _pages[index];
    final features = page['features'] as List<Map<String, dynamic>>;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),

          // Main icon (emoji)
          Text(page['icon'] as String, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 30),

          // Title
          Text(
            page['title'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 25),

          // Telco logos – only on first slide
          if (index == 0) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTelcoLogo('assets/images/BSNL.png'),
                _buildTelcoLogo('assets/images/airtel.png'),
                _buildTelcoLogo('assets/images/jio.png'),
                _buildTelcoLogo('assets/images/vi.png'),
              ],
            ),
            const SizedBox(height: 30),
          ],

          // Feature list
          ...features.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item['icon'] as IconData, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['text'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTelcoLogo(String asset) {
    return Image.asset(
      asset,
      height: 50,
      width: 50,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: Colors.white54),
    );
  }

  // ────────────────────────────────────────────────────────
  // Terms & Conditions page
  // ────────────────────────────────────────────────────────
  Widget _buildTermsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'check_circle Terms & Conditions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Expanded(
            child: SingleChildScrollView(
              child: Text(
                'Please read and accept our Terms & Conditions to continue.\n\n'
                '• Your data will be used for directory and promotional purposes.\n'
                '• You can opt-out at any time via the app.\n'
                '• Using this app implies agreement to our privacy policy.\n'
                '• We do not share your data with third parties without consent.\n'
                '• Messages are sent only to opted-in users.',
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _acceptedTerms,
                activeColor: Colors.white,
                checkColor: Colors.black,
                onChanged: (val) =>
                    setState(() => _acceptedTerms = val ?? false),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'I have read and accept the Terms & Conditions',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // Dots indicator
  // ────────────────────────────────────────────────────────
  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == i ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_currentPage == i ? 1 : 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // Back / Next / Get Started buttons
  // ────────────────────────────────────────────────────────
  Widget _buildButtons() {
    final bool isLastPage = _currentPage == _pages.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Back
        if (_currentPage > 0)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            ),
            child: const Text('Back', style: TextStyle(color: Colors.white)),
          ),

        const SizedBox(width: 12),

        // Next / Get Started
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isLastPage
                ? (_acceptedTerms ? Colors.white : Colors.white54)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          ),
          onPressed: isLastPage
              ? (_acceptedTerms ? _finish : null)
              : () => _controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                ),
          child: Text(
            isLastPage ? 'Get Started' : 'Next',
            style: TextStyle(
              color: isLastPage
                  ? (_acceptedTerms ? Colors.black : Colors.black45)
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

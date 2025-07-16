import 'dart:ui';
import 'package:flutter/material.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;

  final List<Map<String, String>> plans = [
    {
      'title': 'Basic',
      'desc':
      'Ideal for casual riders who need reliable features like basic route tracking, ride history, and limited cloud backup. Get started with the essentials and enjoy seamless connectivity.',
      'price': '\$4.99/month',
    },
    {
      'title': 'Pro',
      'desc':
      'Designed for enthusiasts and racers. Includes everything in Basic plus detailed analytics, live ride sharing, smart alerts, priority support, and weekly performance insights.',
      'price': '\$9.99/month',
    },
    {
      'title': 'Ultimate',
      'desc':
      'For hardcore bikers and professionals. Unlock all premium tools including AI-powered coaching, unlimited cloud storage, exclusive access to beta features, and 24/7 VIP support.',
      'price': '\$14.99/month',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      int next = _controller.page!.round() % plans.length;
      if (_currentIndex != next) {
        setState(() => _currentIndex = next);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getLoopIndex(int index) => index % plans.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Premium',
          style: TextStyle(
            fontFamily: 'Nico Moji',
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: PageView.builder(
            controller: _controller,
            itemBuilder: (context, index) {
              final plan = plans[_getLoopIndex(index)];
              return _buildGlassCard(plan);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(Map<String, String> plan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.5019607843137255),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24, width: 1.5),
              boxShadow: [
                BoxShadow(
                  blurRadius: 15,
                  color: Color.fromRGBO(207, 182, 182, 0.5019607843137255),
                  offset: const Offset(3, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  plan['title']!,
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nico Moji',
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      plan['desc']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  plan['price']!,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Buying ${plan['title']} plan...')),
                    );
                  },
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

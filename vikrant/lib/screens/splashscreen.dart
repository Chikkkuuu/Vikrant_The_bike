import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'onboardingscreen.dart';


class VikrantConnectScreen extends StatefulWidget {
  const VikrantConnectScreen({super.key});

  @override
  State<VikrantConnectScreen> createState() => _VikrantConnectScreenState();
}

class _VikrantConnectScreenState extends State<VikrantConnectScreen> {
  bool showSecondLine = false;

  @override
  void initState() {
    super.initState();

    // Navigate to Onboarding after 5 seconds
    Future.delayed(const Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/unsplash_X6hEndRsYhQ.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Vertical text
            Positioned(
              right: 0,
              top: 62,
              bottom: 80,
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'VIKRANT CONNECT',
                  style: TextStyle(
                    fontFamily: 'Nico Moji',
                    fontSize: 28,
                    color: Color.fromRGBO(175, 238, 238, 0.75),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            // Animated text at bottom
            Positioned(
              top: 160,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontFamily: 'Nico Moji',
                      fontSize: 35,
                      color: Color.fromRGBO(175, 238, 238, 0.75),
                      fontWeight: FontWeight.bold,
                    ),
                    child: AnimatedTextKit(
                      totalRepeatCount: 1,
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Welcome Rider',
                          speed: Duration(milliseconds: 120),
                        ),
                      ],
                      onFinished: () {
                        setState(() {
                          showSecondLine = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (showSecondLine)
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color.fromRGBO(175, 238, 238, 0.75),
                        fontWeight: FontWeight.w500,
                      ),
                      child: AnimatedTextKit(
                        totalRepeatCount: 1,
                        isRepeatingAnimation: false,
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Safe Drive',
                            speed: Duration(milliseconds: 80),
                          ),
                        ],
                      ),
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

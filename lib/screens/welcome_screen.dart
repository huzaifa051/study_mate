import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forest,
      body: Stack(
        children: [
          Positioned(
            top: 80,
            right: -70,
            child: CustomPaint(
              size: const Size(260, 260),
              painter: _RingsPainter(),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STUDYMATE',
                    style: TextStyle(
                      color: AppColors.sage,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Study with\nintention.',
                    style: AppTheme.serif(42, color: AppColors.stone),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'A calmer way to plan, focus and finish what matters.',
                    style: TextStyle(
                      color: Color(0xFFC9D2C4),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.stone,
                        foregroundColor: AppColors.forest,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainShell(),
                          ),
                        );
                      },
                      child: const Text(
                        'Begin',
                        style: TextStyle(fontSize: 16),
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

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radii = [40.0, 80.0, 120.0];
    final alphas = [255, 170, 90];

    for (int i = 0; i < radii.length; i++) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.sage.withAlpha(alphas[i]);
      canvas.drawCircle(center, radii[i], ringPaint);
    }

    final dotPaint = Paint()..color = AppColors.clay;
    canvas.drawCircle(center, 7, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

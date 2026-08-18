import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uniapp/features/quizzes/views/quiz_view.dart';

class ButtonRowLayout extends StatelessWidget {
  const ButtonRowLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: MainQuizButton(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder:
                        (context) => const QuizView(quizTitle: 'Level_200'),
                  ),
                );
              },
              title: 'Start INEG200 QUIZ',
              subtitle: '',
              icon: Icons.play_circle_fill,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              _SmallQuizButton(
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder:
                          (context) => const QuizView(quizTitle: 'Level_300'),
                    ),
                  );
                },
                title: 'INEG300',
                icon: Icons.play_arrow_sharp,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              _SmallQuizButton(
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder:
                          (context) => const QuizView(quizTitle: 'Level_101'),
                    ),
                  );
                },
                title: 'ENGL101',
                icon: Icons.play_arrow_outlined,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MainQuizButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final IconData icon;

  const MainQuizButton({
    super.key,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 210,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallQuizButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final IconData icon;
  final Color color;

  const _SmallQuizButton({
    required this.onTap,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 140,
          height: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.1 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.red, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

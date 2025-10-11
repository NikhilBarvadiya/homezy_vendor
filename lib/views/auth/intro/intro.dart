import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/views/auth/intro/intro_ctrl.dart';

class Intro extends StatelessWidget {
  const Intro({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IntroCtrl>(
      init: IntroCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: ctrl.pageController,
                    onPageChanged: ctrl.onPageChanged,
                    itemCount: ctrl.introPages.length,
                    itemBuilder: (context, index) {
                      return _IntroPage(page: ctrl.introPages[index]);
                    },
                  ),
                ),
                _BottomSection(ctrl: ctrl),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IntroPage extends StatelessWidget {
  final IntroPageModel page;

  const _IntroPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
            child: Icon(page.icon, size: 120, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  final IntroCtrl ctrl;

  const _BottomSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                ctrl.introPages.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: ctrl.currentPage.value == index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: ctrl.onGetStarted, child: Text(ctrl.currentPage.value == ctrl.introPages.length - 1 ? 'Get Started' : 'Next')),
            ),
            const SizedBox(height: 16),
            if (ctrl.currentPage.value != ctrl.introPages.length - 1)
              TextButton(
                onPressed: ctrl.skipIntro,
                child: Text('Skip', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
          ],
        ),
      );
    });
  }
}

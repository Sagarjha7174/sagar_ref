import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/font_scale_provider.dart';
import 'router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final fontScale = ref.watch(fontScaleProvider);

    // Scale the base theme's icon sizes
    final baseTheme = AppTheme.light;
    final scaledTheme = baseTheme.copyWith(
      iconTheme: IconThemeData(
        size: 24.0 * fontScale,
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        iconTheme: IconThemeData(size: 24.0 * fontScale),
        titleTextStyle: baseTheme.textTheme.titleLarge?.copyWith(
          fontSize: (baseTheme.textTheme.titleLarge?.fontSize ?? 22) * fontScale,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        iconTheme: WidgetStateProperty.all(
          IconThemeData(size: 24.0 * fontScale),
        ),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 12.0 * fontScale),
        ),
      ),
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(fontScale),
      ),
      child: MaterialApp.router(
        title: 'Sagar Refrigeration Service',
        theme: scaledTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


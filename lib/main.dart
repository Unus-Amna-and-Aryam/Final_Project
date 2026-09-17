import 'package:final_project/screens/hello_screen.dart';
import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/service/providers_database_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  fvp.registerWith(
    options: {
      'platforms': ['windows', 'linux', 'macos'],
    },
  );

  WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load();
  await Supabase.initialize(
    url: dotenv.get('our_url_key'),
    publishableKey: dotenv.get('our_publishableKey'),
  );


   await testConnection(); 
  // ← تنادي عليها هنا، تحت الـ initialize مباشرة
  runApp(const MainApp());
}

Future<void> testConnection() async {
  try {
    final service = ProvidersDatabaseService();
    final result = await service.getAllProviders();
    print('✅ عدد النتائج: ${result.length}');
  } catch (e, stackTrace) {
    print('❌ خطأ في الاتصال بقاعدة البيانات: $e');
    print('Stack trace: $stackTrace');
  }
}

// Android's default stretch-overscroll indicator visually deforms
// ("stretches") the whole screen whenever a scroll view is dragged past its
// content bounds — reported on both question_screen.dart's long "needs"
// list and RecommendedPlanScreen's scrollable body. Disabling it here, once,
// for every scrollable in the app (rather than per-screen) means neither any
// existing screen nor a future one can hit this again by omission.
class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: _AppScrollBehavior(),
      home: const HelloScreen(),
    );
  }
}

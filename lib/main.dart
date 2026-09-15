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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HelloScreen(),
    );
  }
}

// مو هنا بالمين
// بعدين في أي مكان بالكود تقدر توصل للعميل عن طريق:
//final supabase = Supabase.instance.client;

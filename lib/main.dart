import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase if keys are provided
  if (SupabaseOptions.anonKey != 'YOUR_SUPABASE_ANON_KEY') {
    await Supabase.initialize(
      url: SupabaseOptions.url,
      anonKey: SupabaseOptions.anonKey,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KoreaQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          primary: const Color(0xFFE53935),
          secondary: const Color(0xFF1E88E5),
        ),
        useMaterial3: true,
      ),
      home: const SupabaseStatusPage(),
    );
  }
}

class SupabaseStatusPage extends StatelessWidget {
  const SupabaseStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isConfigured =
        SupabaseOptions.anonKey != 'YOUR_SUPABASE_ANON_KEY';

    return Scaffold(
      appBar: AppBar(
        title: const Text('🇰🇷 KOREAQUEST - Supabase Status'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isConfigured ? Icons.check_circle : Icons.cloud_off,
                size: 72,
                color: isConfigured ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                isConfigured
                    ? 'Connected to Supabase!'
                    : 'Supabase Configuration Pending',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Project ID: rsswzbgqapvrutcqasqv\nURL: ${SupabaseOptions.url}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Next Step:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isConfigured
                            ? 'Ready to build tables & authentication flows.'
                            : 'Paste your Supabase `anonKey` in lib/supabase_options.dart',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_supabase_auth/signin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhYW11aHpmcGZkdmZha2RmemV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDE5NjgxOTEsImV4cCI6MjAxNzU0NDE5MX0.3oRlKrnP3oRs0uck4G5rgDkebdkehGVmd_YG_pSprvI',
      url: 'https://gaamuhzfpfdvfakdfzew.supabase.co URL');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter X Supabase Auth')),
        body: const SignIn(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import 'views/form_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  SolanaWalletAdapterPlatform.instance.setProvider(AppInfo.phantom);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alpha White Label Lead Generator',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple.shade800),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color.fromRGBO(15, 23, 42, 1)),
      home: const FormPage(),
    );
  }
}

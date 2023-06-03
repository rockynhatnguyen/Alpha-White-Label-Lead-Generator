import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;

void main() {
  SolanaWalletAdapterPlatform.instance.setProvider(AppInfo.phantom);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Phantom Wallet Connect'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final adapter = SolanaWalletAdapter(
    const AppIdentity(),
    // uri: Uri.https('merigo.com'),
    // icon: Uri.parse('favicon.png'),
    // name: 'Example App',
    //),
    // NOTE: CONNECT THE WALLET APPLICATION
    // TO THE SAME NETWORK.
    cluster: Cluster.devnet,
  );

  Object? output;
  dynamic capturedError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                adapter.authorize().then((result) {
                  if (result is AuthorizeResult) {
                    setState(() {
                      output = result;
                      setState(() {
                        capturedError = null;
                      });
                    });
                  }
                }).catchError((error) {
                  debugPrint('Error: ${error.toString()}');

                  setState(() {
                    capturedError = error.toString();
                    debugPrint('testing: ${capturedError.toString()}');
                  });
                  if (error.toString() ==
                          'Assertion failed: "Desktop implementations must call setProvider() first."' ||
                      error.toString() ==
                          "[SolanaException<SolanaWalletAdapterExceptionCode>] SolanaWalletAdapterExceptionCode.walletNotFound : The wallet application could not be opened.") {
                    debugPrint('Launching Phantom Wallet Connect');
                    setState(() {
                      capturedError =
                          capturedError + " (Phantom Wallet Not Found)";
                    });
                    final appId =
                        Theme.of(context).platform == TargetPlatform.android
                            ? AppInfo.phantom.androidId
                            : AppInfo.phantom.iosId;
                    if (Theme.of(context).platform == TargetPlatform.iOS) {
                      launchUrlString('https://phantom.app/');
                    } else if (Theme.of(context).platform ==
                        TargetPlatform.android) {
                      launchUrlString('market://details?id=$appId');
                    } else {
                      launchUrlString('https://phantom.app/');
                    }
                  }
                });
              },
              child: const Text('Wallet Connect'),
            ),
            Text(
                'Address: ${SolanaWalletAdapterPlatform.instance.connectedAccount?.addressBase58}'),
            Text(capturedError.toString()),
          ],
        ),
      ),
    );
  }
}

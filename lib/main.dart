import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:white_label_tpr/components/error_box.dart';

void main() {
  SolanaWalletAdapterPlatform.instance.setProvider(AppInfo.phantom);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.dark),
      home: MyHomePage(title: 'Flutter Phantom Wallet Connect'),
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
  var adapter = SolanaWalletAdapter(
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
  bool switchValue = true;

  // Dialog for Install phantom wallet?
  void _showAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Install Phantom Wallet?'),
        content: const Text(
            'Phantom Wallet was not detected on this system. Would you like to go to the install page?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              final appId = Theme.of(context).platform == TargetPlatform.android
                  ? AppInfo.phantom.androidId
                  : AppInfo.phantom.iosId;
              if (Theme.of(context).platform == TargetPlatform.iOS) {
                launchUrlString('https://apps.apple.com/app/$appId');
              } else if (Theme.of(context).platform == TargetPlatform.android) {
                launchUrlString('market://details?id=$appId');
              } else {
                launchUrlString('https://phantom.app/');
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  onSwitchChanged(bool value) {
    setState(() {
      switchValue = value;
      adapter = SolanaWalletAdapter(
        const AppIdentity(),
        cluster: switchValue ? Cluster.devnet : Cluster.mainnet,
      );
      adapter.authorize();
    });
  }

  getAddress() =>
      SolanaWalletAdapterPlatform.instance.connectedAccount?.addressBase58 ??
      'No Address Available';

  isConnected() =>
      SolanaWalletAdapterPlatform.instance.connectedAccount?.address != null;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Phantom Wallet Connect Example"),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Address: ${getAddress()}'),
            GestureDetector(
              onTap: () {
                onSwitchChanged(!switchValue);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Use Devnet',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const SizedBox(width: 24),
                  CupertinoSwitch(
                    value: switchValue,
                    activeColor: CupertinoColors.activeBlue,
                    onChanged: (value) {
                      onSwitchChanged(value);
                    },
                  ),
                ],
              ),
            ),
            CupertinoButton.filled(
              disabledColor: CupertinoColors.systemGrey,
              onPressed: isConnected()
                  ? null
                  : () async {
                      adapter.authorize().then((result) {
                        setState(() {
                          output = result;
                          setState(() {
                            capturedError = null;
                          });
                        });
                      }).catchError((error) {
                        debugPrint('Error: ${error.toString()}');

                        if (error.toString() ==
                                'Assertion failed: "Desktop implementations must call setProvider() first."' ||
                            error.toString() ==
                                "[SolanaException<SolanaWalletAdapterExceptionCode>] SolanaWalletAdapterExceptionCode.walletNotFound : The wallet application could not be opened.") {
                          debugPrint('Launching Phantom Wallet Connect');
                          _showAlertDialog(context);
                          // We may not need to consider this an error because we know the wallet is not there
                          // setState(() {
                          //   capturedError =
                          //       capturedError + " (Phantom Wallet Not Found)";
                          // });
                        } else {
                          setState(() {
                            capturedError = error.toString();
                            debugPrint('testing: ${capturedError.toString()}');
                          });
                        }
                      });
                    },
              child:
                  Text(isConnected() ? "Wallet Connected!" : "Connect Wallet"),
            ),
            if (capturedError != null)
              ErrorBox(
                  errorMessage: capturedError,
                  onClose: () {
                    setState(() {
                      capturedError = null;
                    });
                  })
          ],
        ),
      ),
    );
  }
}

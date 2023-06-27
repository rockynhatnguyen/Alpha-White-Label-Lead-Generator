import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import 'package:wl_lead_generator/utils.dart';
import 'package:wl_lead_generator/widgets/countdown.dart';
import 'package:wl_lead_generator/widgets/message_box.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'result_page.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  FormPageState createState() => FormPageState();
}

class FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  AuthorizeResult? _output;
  String? _capturedAddress;

  // Create instance of [SolanaWalletAdapter].
  final adapter = SolanaWalletAdapter(
    const AppIdentity(name: 'Solana Lead Generator'),
    // uri: Uri.https('merigo.com'),
    // icon: Uri.parse('favicon.png'),
    // name: 'Example App',

    // NOTE: CONNECT THE WALLET APPLICATION TO THE SAME NETWORK.
    cluster: Cluster.mainnet,
  );

  bool _optIn = false;
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _countryCode;
  String? _mobileNumber;
  String? _twitterHandle;
  String? _discordHandle;
  String? walletAddress;

  // Wallet not found modal
  Future<void> _showPhantomModal() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Phantom Wallet not found'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Phantom Wallet was not detected on this system. Would you like to go to the install page?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                final appId =
                    Theme.of(context).platform == TargetPlatform.android
                        ? AppInfo.phantom.androidId
                        : AppInfo.phantom.iosId;
                if (Theme.of(context).platform == TargetPlatform.iOS) {
                  launchUrlString('https://apps.apple.com/app/$appId');
                } else if (Theme.of(context).platform ==
                    TargetPlatform.android) {
                  launchUrlString('market://details?id=$appId');
                } else {
                  launchUrlString('https://phantom.app/');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _showOptOutDialog() async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        bool optInLocal = _optIn;
        String twitterHandleLocal = _twitterHandle ?? '';
        String discordHandleLocal = _discordHandle ?? '';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Opt Out Warning'),
              content: Column(
                children: [
                  const Text(
                      'Are you sure you do not want to miss out on those awesome updates that gives you access to exclusive New Sacred merchandise and opportunities to participate in events that benefits you'),
                  const Text('To opt in, please fill BOTH fields.'),
                  TextFormField(
                    initialValue: _twitterHandle,
                    decoration:
                        const InputDecoration(labelText: 'Twitter Handle'),
                    onChanged: (value) {
                      twitterHandleLocal = value;
                    },
                    validator: (value) {
                      if (optInLocal == true &&
                          (value == null || value.isEmpty)) {
                        return 'Please enter your twitter handle';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _discordHandle,
                    decoration: const InputDecoration(labelText: 'Discord ID'),
                    onChanged: (value) {
                      discordHandleLocal = value;
                    },
                    validator: (value) {
                      if (optInLocal == true &&
                          (value == null || value.isEmpty)) {
                        return 'Please enter your discord ID';
                      }
                      return null;
                    },
                  ),
                  CheckboxListTile(
                    title: const Text("Opt-in for updates."),
                    value: optInLocal,
                    onChanged: (bool? value) {
                      setState(() {
                        optInLocal = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    Navigator.of(context).pop({
                      'optIn': false,
                      'twitterHandle': twitterHandleLocal,
                      'discordHandle': discordHandleLocal,
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _optIn =
              (value['twitterHandle'] != null && value['discordHandle'] != null)
                  ? value['optIn']
                  : false;
        });
        handleSubmit();
      }
      return value ?? {};
    });
  }

  // Submit data
  Future<int> submitData() async {
    final url = Utils.getPostFormEndpoint();

    // Create a map of the data to be sent
    final data = {
      'firstName': _firstName,
      'lastName': _lastName,
      'email': _email,
      'countryCode': _countryCode,
      'mobileNumber': _mobileNumber,
      'twitterHandle': _twitterHandle,
      'discordHandle': _discordHandle,
      'optIn': _optIn,
      'solAddress': walletAddress,
    };

    final headers = {
      'Content-Type': 'application/json',
    };

    final jsonData = json.encode(data);

    // Send a POST request to the server
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonData,
    );

    // Check the response status
    if (response.statusCode == 200) {
      // Data submitted successfully
      debugPrint('Data submitted successfully');
    } else {
      // Error occurred while submitting data
      debugPrint('Error submitting data. Status code: ${response.statusCode}');
    }

    return response.statusCode;
  }

  Future<void> handleSubmit() async {
    submitData().then((value) {
      _formKey.currentState!.reset();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            statusCode: value,
            firstName: _firstName!,
            lastName: _lastName!, // replace with actual value
            email: _email!,
            countryCode: _countryCode,
            mobileNumber: _mobileNumber,
            twitterHandle: _twitterHandle,
            discordHandle: _discordHandle,
            optedIn: _optIn,
            walletAddress: walletAddress!,
          ),
        ),
      );
    }).catchError((error) {
      debugPrint('Error: ${error.toString()}');
      setState(() {
        capturedError = error.toString();
      });
    });
  }

  Object? output;
  dynamic capturedError;
  bool switchValue = true;

  @override
  Widget build(BuildContext context) {
    TextEditingController txtController = TextEditingController(
      text: walletAddress == null
          ? "Address: $walletAddress"
          : "No Wallet Address Captured",
    );

    return Scaffold(
      appBar: buildAppBar() as AppBar,
      body: buildBody(txtController),
    );
  }

  Widget buildAppBar() {
    return AppBar(
        title: const Text(
          'Solectiq Leads',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white70,
          ),
        ),
        backgroundColor: const Color.fromRGBO(15, 23, 42, 1),
        elevation: 0);
  }

  Widget buildBody(TextEditingController txtController) {
    TextEditingController txtController = TextEditingController(
        text: walletAddress ?? "No Wallet Address Captured");
    return Container(
      color: const Color.fromRGBO(15, 23, 42, 1),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Image.asset(
                  'assets/logo/logo.png',
                  height: 80.0,
                  width: 80.0,
                ),
              ),
              const SizedBox(height: 10.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    buildFormField(
                      labelText: 'First Name',
                      hintText: 'Enter your first name',
                      isRequired: true,
                      onSaved: (value) {
                        _firstName = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18.0),
                    buildFormField(
                      labelText: 'Last Name',
                      hintText: 'Enter your last name',
                      isRequired: true,
                      onSaved: (value) {
                        _lastName = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18.0),
                    buildFormField(
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                      isRequired: true,
                      onChanged: (value) {
                        _email = value;
                      },
                      validator: (value) {
                        RegExp emailRegex = RegExp(
                            r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18.0),
                    PhoneFormField(
                      key: const Key('phone-field'),
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelStyle: const TextStyle(
                            color: Colors.white60, fontSize: 16.0),
                      ),
                      defaultCountry: IsoCode.US,
                      showDialCode: true,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.purpleAccent,
                      onChanged: (phone) {
                        _mobileNumber = phone?.countryCode;
                        debugPrint('debug:$phone');
                      },
                    ),
                    const SizedBox(height: 18.0),
                    buildFormField(
                      labelText: 'Twitter Handle',
                      hintText: 'Enter your Twitter handle',
                      isRequired: _optIn,
                      onChanged: (value) {
                        _twitterHandle = value;
                      },
                      validator: (value) {
                        if (_optIn == true &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter your Twitter handle';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18.0),
                    buildFormField(
                      labelText: 'Discord Handle',
                      hintText: 'Enter your Discord Handle',
                      isRequired: _optIn,
                      onChanged: (value) {
                        _discordHandle = value;
                      },
                      validator: (value) {
                        if (_optIn == true &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter your Discord handle';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18.0),
                    CheckboxListTile(
                      title: const Text(
                        "Opt in for updates (We use Twitter & Discord)",
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _optIn,
                      onChanged: (bool? value) {
                        setState(() {
                          _optIn = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 18.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 8.0),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextFormField(
                            enabled: false,
                            controller: txtController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your wallet address',
                              hintStyle: TextStyle(color: Colors.white54),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    if (walletAddress == null)
                      ElevatedButton(
                        onPressed: connectWallet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA855F7),
                          foregroundColor: Colors.white,
                          fixedSize: const Size(200, 50),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        child: const Text('Connect Wallet'),
                      ),
                    const SizedBox(height: 24.0),
                    if (walletAddress != null)
                      ElevatedButton(
                        onPressed: submitLead,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA855F7),
                          foregroundColor: Colors.white,
                          fixedSize: const Size(200, 50),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        child: const Text('Submit Lead'),
                      ),
                    if (_output != null) Text('Address: $_capturedAddress'),
                    const SizedBox(height: 18.0),
                    const CountDown(),
                    if (capturedError != null)
                      MessageBox(
                        type: MessageType.error,
                        message: capturedError,
                        onClose: () {
                          setState(() {
                            capturedError = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFormField({
    required hintText,
    required String labelText,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    Widget? child,
  }) {
    const TextStyle labelStyle = TextStyle(
      color: Colors.white60,
      fontSize: 16.0,
    );
    final String requiredLabel = isRequired ? '$labelText *' : labelText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          requiredLabel,
          style: labelStyle,
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.white54),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white60),
            onChanged: onChanged,
            onSaved: onSaved,
            validator: validator,
          ),
        ),
      ],
    );
  }

  void connectWallet() async {
    adapter.authorize().then((result) {
      setState(() {
        output = result;
        walletAddress = result.accounts.first.addressBase58.toString();
        capturedError = null;
      });
    }).catchError((error) {
      debugPrint('Error: ${error.toString()}');

      if (error.toString() ==
              'Assertion failed: "Desktop implementations must call setProvider() first."' ||
          error.toString() ==
              "[SolanaException<SolanaWalletAdapterExceptionCode>] SolanaWalletAdapterExceptionCode.walletNotFound : The wallet application could not be opened.") {
        debugPrint('Launching Phantom Wallet Connect');
        _showPhantomModal();
      }
    });
  }

  void submitLead() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (!_optIn) {
        await _showOptOutDialog();
        // The modal will handle it from here
        return;
      }

      handleSubmit();
    }
  }
}

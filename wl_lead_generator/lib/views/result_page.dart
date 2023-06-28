import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wl_lead_generator/utils.dart';
import 'package:wl_lead_generator/widgets/countdown.dart';
import 'package:wl_lead_generator/widgets/message_box.dart';
import 'form_page.dart';

class ResultPage extends StatefulWidget {
  final int statusCode;
  final String firstName;
  final String lastName;
  final String email;
  final String? countryCode;
  final String? mobileNumber;
  final String? twitterHandle;
  final String? discordHandle;
  final bool optedIn;
  final String walletAddress;

  const ResultPage({
    Key? key,
    required this.statusCode,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.twitterHandle,
    required this.discordHandle,
    required this.optedIn,
    required this.walletAddress,
  }) : super(key: key);

  @override
  ResultPageState createState() => ResultPageState();
}

class ResultPageState extends State<ResultPage> {
  String? _twitterHandle;
  String? _discordHandle;
  bool _optedIn = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  MessageType? _messageType;
  String? _message;

  @override
  void initState() {
    super.initState();
    _twitterHandle = widget.twitterHandle;
    _discordHandle = widget.discordHandle;
    _optedIn = widget.optedIn;
  }

  String? optInStatusCode;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final status = await _updateOptIn(
        widget.walletAddress, _discordHandle, _twitterHandle);

    setState(() {
      optInStatusCode = status.toString();
    });

    if (status == 200) {
      _showMessageBox('Opt-in submitted successfully!', MessageType.success);

      debugPrint('Form submitted successfully!');
    } else {
      _showMessageBox('Failed to submit the opt-in.', MessageType.error);
      debugPrint('Failed to submit the form.');
    }
  }

  Future<int> _updateOptIn(
      String solAddress, String? discordHandle, String? twitterHandle) async {
    try {
      final url = Uri.parse(Utils.getUpdateOptinEndpoint());
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'solAddress': solAddress,
          'discordHandle': discordHandle ?? '',
          'twitterHandle': twitterHandle ?? '',
        }),
      );

      return response.statusCode;
    } catch (e) {
      return 400;
    }
  }

  void _showMessageBox(String message, MessageType type) {
    setState(() {
      _message = message;
      _messageType = type;
    });
  }

  Widget _buildUserDetail(String title, String? detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            detail ?? 'Not provided',
            style: const TextStyle(fontSize: 16, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBox() {
    if (_message != null && _messageType != null) {
      return MessageBox(
        message: _message!,
        type: _messageType!,
        onClose: () {
          setState(() {
            _message = null;
            _messageType = null;
          });
        },
      );
    }
    return const SizedBox.shrink();
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

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      appBar: buildAppBar() as AppBar,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: widget.statusCode == 200
                      ? Colors.green[300]
                      : Colors.red[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(16),
                child: widget.statusCode == 200
                    ? Text(
                        'Congratulations ${widget.firstName} ${widget.lastName}! You are now connected to New Sacred.',
                        style: themeData.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Could not connect to the wallet or server. Give it another try! ',
                        style: themeData.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 20.0),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildUserDetail('First Name: ', widget.firstName),
                    _buildUserDetail('Last Name: ', widget.lastName),
                    _buildUserDetail('Email: ', widget.email),
                    _buildUserDetail('Mobile Number: ',
                        "${widget.countryCode ?? ''}${widget.mobileNumber ?? 'Not Provided'}"),
                    _buildUserDetail('Wallet Address: ', widget.walletAddress),
                    _buildUserDetail("Chose to Opt In: ",
                        widget.optedIn.toString().toUpperCase()),
                    if (widget.optedIn)
                      _buildUserDetail(
                          'Twitter Handle: ', widget.twitterHandle),
                    if (widget.optedIn)
                      _buildUserDetail(
                          'Discord Handle: ', widget.discordHandle),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (widget.statusCode == 200)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Update Opt-in',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _optedIn,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _optedIn = newValue ?? false;
                                      });
                                    },
                                  ),
                                  const Text(
                                    "Opt in for updates",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (_optedIn)
                                _buildFormField(
                                    hintText: 'Discord Handle',
                                    labelText: 'Discord Handle',
                                    initialValue: _discordHandle ?? '',
                                    isRequired: true,
                                    onChanged: (value) {
                                      setState(() {
                                        _discordHandle = value;
                                      });
                                    }),
                              const SizedBox(height: 10),
                              if (_optedIn)
                                _buildFormField(
                                    hintText: 'Twitter Handle',
                                    labelText: 'Twitter Handle',
                                    initialValue: _twitterHandle ?? '',
                                    isRequired: true,
                                    onChanged: (value) {
                                      setState(() {
                                        _twitterHandle = value;
                                      });
                                    }),
                              const SizedBox(height: 10),
                              if (_optedIn)
                                ElevatedButton(
                                  onPressed: _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFFA855F7),
                                    fixedSize: const Size(200, 50),
                                  ),
                                  child: const Text(
                                    'Resubmit Opt In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      _buildMessageBox(),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              const CountDown(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFA855F7),
                  fixedSize: const Size(200, 50),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required hintText,
    required String labelText,
    required String initialValue,
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
            initialValue: initialValue,
          ),
        ),
      ],
    );
  }
}

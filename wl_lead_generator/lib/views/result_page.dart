import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wl_lead_generator/widgets/message_box.dart';
import 'landing_page.dart';

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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final solAddress = widget.walletAddress;
    final discordID = _discordHandle;
    final twitterHandle = _twitterHandle;

    final bool success =
        await _updateOptIn(solAddress, discordID, twitterHandle);

    if (success) {
      _showMessageBox('Opt-in submitted successfully!', MessageType.Success);
      print('Form submitted successfully!');
    } else {
      _showMessageBox('Failed to submit the opt-in.', MessageType.Error);
      print('Failed to submit the form.');
    }
  }

  Future<bool> _updateOptIn(
    String solAddress,
    String? discordHandle,
    String? twitterHandle,
  ) async {
    try {
      final url = Uri.parse('http://localhost:3000/update-optin');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'solAddress': solAddress,
          'discordHandle': discordHandle ?? '',
          'twitterHandle': twitterHandle ?? '',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _showMessageBox(String message, MessageType type) {
    setState(() {
      _message = message;
      _messageType = type;
    });
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
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Back to Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.statusCode == 200)
              Text(
                'Congratulations: ${widget.firstName} ${widget.lastName}!! You are now connected to New Sacred',
              ),
            Text(
              'First Name: ${widget.firstName}',
            ),
            Text(
              'Last Name: ${widget.lastName}',
            ),
            Text(
              'Email: ${widget.email}',
            ),
            Text(
              'Country Code: ${widget.countryCode ?? 'Not provided'}',
            ),
            Text(
              'Mobile Number: ${widget.mobileNumber ?? 'Not provided'}',
            ),
            Text(
              'Twitter Handle: ${_twitterHandle ?? 'Not provided'}',
            ),
            Text(
              'Discord Handle: ${_discordHandle ?? 'Not provided'}',
            ),
            Text(
              'Wallet Address: ${widget.walletAddress}',
            ),
            _buildMessageBox(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CheckboxListTile(
                        title: const Text("Opt in for updates"),
                        value: _optedIn,
                        onChanged: (newValue) {
                          setState(() {
                            _optedIn = newValue ?? false;
                          });
                        },
                      ),
                      if (_optedIn)
                        TextFormField(
                          initialValue: _twitterHandle,
                          decoration: const InputDecoration(
                              labelText: 'Twitter Handle'),
                          enabled: _optedIn,
                          onChanged: (value) {
                            _twitterHandle = value;
                          },
                          validator: (value) {
                            if (_optedIn == true &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter your twitter handle';
                            }
                            return null;
                          },
                        ),
                      if (_optedIn)
                        TextFormField(
                          initialValue: _discordHandle,
                          decoration:
                              const InputDecoration(labelText: 'Discord ID'),
                          onChanged: (value) {
                            _discordHandle = value;
                          },
                          enabled: _optedIn,
                          validator: (value) {
                            if (_optedIn == true &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter your discord ID';
                            }
                            return null;
                          },
                        ),
                      if (_optedIn)
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Submit'),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LandingPage()),
                          );
                        },
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.statusCode != 200)
              Text(
                'Could not connect to the wallet or server. Give it another try! Status code: ${widget.statusCode}',
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

enum MessageType {
  error,
  success,
}

class MessageBox extends StatelessWidget {
  final String message;
  final MessageType type;
  final VoidCallback onClose;

  const MessageBox({
    Key? key,
    required this.message,
    required this.type,
    required this.onClose,
  }) : super(key: key);

  Color _getColor() {
    switch (type) {
      case MessageType.error:
        return Colors.red;
      case MessageType.success:
        return Colors.green;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case MessageType.error:
        return Icons.error;
      case MessageType.success:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: _getColor(),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: Icon(
                _getIcon(),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

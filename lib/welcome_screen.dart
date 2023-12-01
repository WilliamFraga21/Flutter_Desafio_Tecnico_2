import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onAccept;

  WelcomeScreen({required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-Vindo!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Seja bem-vindo ao nosso aplicativo!'),
            Text(
              'Para aproveitar ao máximo, precisamos de algumas permissões.',
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: onAccept,
              child: Text('Aceitar Permissões'),
            ),
          ],
        ),
      ),
    );
  }
}

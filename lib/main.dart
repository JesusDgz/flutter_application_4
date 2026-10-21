import 'dart:convert';

import 'package:flutter/material.dart';

import 'encrypted_json_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Almacenamiento seguro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SecureStoragePage(),
    );
  }
}

class SecureStoragePage extends StatefulWidget {
  const SecureStoragePage({super.key});

  @override
  State<SecureStoragePage> createState() => _SecureStoragePageState();
}

class _SecureStoragePageState extends State<SecureStoragePage> {
  static const _filename = 'user_data.json';
  final _storage = EncryptedJsonStorage();
  final _jsonController = TextEditingController(
    text: '{\n  "name": "Ada Lovelace",\n  "role": "Pionera de la programación"\n}',
  );
  Map<String, dynamic>? _loadedData;
  bool _isBusy = false;
  String _message = 'Aún no hay datos cargados.';

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    setState(() => _isBusy = true);
    try {
      final decoded = jsonDecode(_jsonController.text);
      if (decoded is! Map<String, dynamic>) {
        setState(
          () => _message = 'El JSON debe ser un objeto con pares clave-valor.',
        );
        return;
      }
      await _storage.saveEncryptedJson(_filename, decoded);
      if (!mounted) return;
      setState(() => _message = 'Datos guardados y cifrados correctamente.');
    } on FormatException {
      setState(() => _message = 'El texto no contiene un JSON válido.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _readData() async {
    setState(() => _isBusy = true);
    try {
      final data = await _storage.readEncryptedJson(_filename);
      if (!mounted) return;
      setState(() {
        _loadedData = data;
        if (data != null) {
          _jsonController.text = const JsonEncoder.withIndent('  ')
              .convert(data);
        }
        _message = data == null
            ? 'No existe un archivo válido para leer.'
            : 'Datos descifrados correctamente.';
      });
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _loadedData;

    return Scaffold(
      appBar: AppBar(title: const Text('JSON cifrado con AES')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Persistencia local segura',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(_message, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  TextField(
                    key: const Key('json-editor'),
                    controller: _jsonController,
                    minLines: 7,
                    maxLines: 12,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: 'JSON',
                      hintText: '{ "name": "Tu nombre" }',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (data != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          const JsonEncoder.withIndent('  ').convert(data),
                          key: const Key('loaded-json'),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isBusy ? null : _saveData,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar JSON cifrado'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isBusy ? null : _readData,
                    icon: const Icon(Icons.lock_open_outlined),
                    label: const Text('Leer y descifrar JSON'),
                  ),
                  if (_isBusy) ...[
                    const SizedBox(height: 20),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

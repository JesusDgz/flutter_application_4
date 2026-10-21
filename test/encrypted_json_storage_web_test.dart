import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_4/encrypted_json_storage.dart';

void main() {
  test('save and read encrypted JSON on web without path_provider', () async {
    final storage = EncryptedJsonStorage();
    const filename = 'web_storage_test.json';
    final data = {
      'name': 'Ada Lovelace',
      'role': 'Pionera de la programación',
    };

    await storage.saveEncryptedJson(filename, data);
    final loaded = await storage.readEncryptedJson(filename);

    expect(loaded, data);
  });
}

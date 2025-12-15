import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/providers/auth_provider.dart';

void main() {
  group('AuthProvider', () {
    test('Initial state is not authenticated', () {
      final auth = AuthProvider();
      expect(auth.isAuthenticated, false);
      expect(auth.token, null);
    });

    // We can't easily test HTTP calls without mocking http.Client,
    // but we can test the state logic if we refactor to inject Client.
    // For now, let's just test the initial state which confirms the provider setup.
  });
}

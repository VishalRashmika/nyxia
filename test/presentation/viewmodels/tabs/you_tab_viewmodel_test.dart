import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/data/repositories/auth_service/auth_service.dart';
import 'package:nyxia/presentation/viewmodels/tabs/you_tab_viewmodel.dart';

class FakeUser implements User {
  final String? name;
  final String? mail;
  final String? photo;

  FakeUser({this.name, this.mail, this.photo});

  @override
  String? get displayName => name;

  @override
  String? get email => mail;

  @override
  String? get photoURL => photo;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeAuthService extends AuthService {
  User? fakeCurrentUser;
  Object? signOutError;

  @override
  User? get currentUser => fakeCurrentUser;

  @override
  Future<void> signOut() async {
    if (signOutError != null) {
      throw signOutError!;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // initialize firebase for auth service test doubles
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  group('you_tab_viewmodel_tests', () {
    test('user getters return fallback values when user is null', () {
      // this test verifies fallback values without authenticated user.
      final auth = FakeAuthService()..fakeCurrentUser = null;
      final vm = YouTabViewModel(auth);

      expect(vm.userName, 'User');
      expect(vm.userEmail, 'No email');
      expect(vm.userPhotoUrl, isNull);
      expect(vm.hasProfilePhoto, isFalse);
    });

    test('user getters return values from current user', () {
      // this test verifies user getters map authenticated user fields.
      final auth = FakeAuthService()
        ..fakeCurrentUser = FakeUser(
          name: 'Jane Doe',
          mail: 'jane@example.com',
          photo: 'https://example.com/p.jpg',
        );
      final vm = YouTabViewModel(auth);

      expect(vm.userName, 'Jane Doe');
      expect(vm.userEmail, 'jane@example.com');
      expect(vm.userPhotoUrl, 'https://example.com/p.jpg');
      expect(vm.hasProfilePhoto, isTrue);
    });

    test('getThemeName maps known and unknown values', () {
      // this test verifies theme name mapping behavior.
      final vm = YouTabViewModel(FakeAuthService());

      expect(vm.getThemeName('light'), 'Light Mode');
      expect(vm.getThemeName('dark'), 'Dark Mode');
      expect(vm.getThemeName('night'), 'Night Mode');
      expect(vm.getThemeName('other'), 'Light Mode');
    });

    test('logout returns false when signOut throws', () async {
      // this test verifies logout failure behavior.
      final auth = FakeAuthService()..signOutError = Exception('signout');
      final vm = YouTabViewModel(auth);

      final result = await vm.logout();

      expect(result, isFalse);
    });
  });
}

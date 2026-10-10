import 'dart:async';

import 'package:korea_quest/features/auth/domain/auth_models.dart';
import 'package:korea_quest/features/auth/domain/auth_repository.dart';

class _AccountRecord {
  const _AccountRecord({required this.user, required this.password});

  final AuthUser user;
  final String password;
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    _accounts['admin'] = const _AccountRecord(
      user: AuthUser(
        id: 'admin-001',
        usernameOrEmail: 'admin',
        displayName: 'Quản trị viên',
        role: UserRole.admin,
      ),
      password: 'admin123',
    );
    _accounts['duong@example.com'] = const _AccountRecord(
      user: AuthUser(
        id: 'user-001',
        usernameOrEmail: 'duong@example.com',
        displayName: 'Phạm Văn Dương',
        role: UserRole.user,
      ),
      password: 'user123',
    );
  }

  final _userController = StreamController<AuthUser?>.broadcast();
  final _accounts = <String, _AccountRecord>{};
  AuthUser? _currentUser;
  var _nextUserId = 2;

  void dispose() {
    _userController.close();
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> watchCurrentUser() async* {
    yield _currentUser;
    yield* _userController.stream;
  }

  @override
  Future<AuthUser> signIn({
    required String identity,
    required String password,
  }) async {
    final key = identity.trim().toLowerCase();
    final record = _accounts[key];
    if (record == null) {
      throw const AuthException('Tài khoản không tồn tại trong hệ thống.');
    }
    if (record.password != password) {
      throw const AuthException('Mật khẩu không chính xác.');
    }
    _currentUser = record.user;
    _userController.add(_currentUser);
    return record.user;
  }

  @override
  Future<AuthUser> signInAsGuest({required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const AuthException('Vui lòng nhập tên của bạn.');
    }
    final guestUser = AuthUser(
      id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      usernameOrEmail: 'guest@koreaquest.local',
      displayName: trimmed,
      role: UserRole.user,
      isGuest: true,
    );
    _currentUser = guestUser;
    _userController.add(_currentUser);
    return guestUser;
  }

  @override
  Future<AuthUser> register({
    required String fullName,
    required String displayName,
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    if (key.isEmpty) {
      throw const AuthException('Email không được để trống.');
    }
    if (!_isValidEmail(key)) {
      throw const AuthException('Email không đúng định dạng.');
    }
    if (password.length < 8) {
      throw const AuthException('Mật khẩu phải có ít nhất 8 ký tự.');
    }
    if (_accounts.containsKey(key)) {
      throw const AuthException('Email hoặc tên đăng nhập đã được sử dụng.');
    }

    final newUser = AuthUser(
      id: 'user-${_nextUserId++}',
      usernameOrEmail: key,
      displayName: displayName.trim().isEmpty
          ? fullName.trim()
          : displayName.trim(),
      role: UserRole.user,
    );

    _accounts[key] = _AccountRecord(user: newUser, password: password);
    _currentUser = newUser;
    _userController.add(_currentUser);
    return newUser;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    final key = email.trim().toLowerCase();
    if (!_isValidEmail(key)) {
      throw const AuthException('Email không đúng định dạng.');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw const AuthException('Bạn chưa đăng nhập.');
    }
    final key = user.usernameOrEmail.trim().toLowerCase();
    final record = _accounts[key];
    if (record == null) {
      throw const AuthException('Tài khoản không tồn tại.');
    }
    if (record.password != currentPassword) {
      throw const AuthException('Mật khẩu hiện tại không chính xác.');
    }
    if (newPassword.length < 8) {
      throw const AuthException('Mật khẩu mới phải có ít nhất 8 ký tự.');
    }
    _accounts[key] = _AccountRecord(user: record.user, password: newPassword);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _userController.add(null);
  }

  bool _isValidEmail(String value) {
    final at = value.indexOf('@');
    return at > 0 && at < value.length - 3 && value.indexOf('.', at) > at + 1;
  }
}

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
    if (password.length < 6) {
      throw const AuthException('Mật khẩu phải có ít nhất 6 ký tự.');
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
  Future<void> signOut() async {
    _currentUser = null;
    _userController.add(null);
  }
}

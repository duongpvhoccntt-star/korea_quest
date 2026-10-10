import 'package:korea_quest/features/auth/domain/auth_models.dart';
import 'package:korea_quest/features/auth/domain/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client) {
    final user = _client.auth.currentUser;
    if (user != null) {
      _currentUser = _mapUser(user, role: UserRole.user);
    }
  }

  final supabase.SupabaseClient _client;
  AuthUser? _currentUser;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> watchCurrentUser() async* {
    final initialUser = _client.auth.currentUser;
    if (initialUser != null) {
      _currentUser = await _loadUser(initialUser);
    } else {
      _currentUser = null;
    }
    yield _currentUser;

    yield* _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      _currentUser = user == null ? null : await _loadUser(user);
      return _currentUser;
    });
  }

  @override
  Future<AuthUser> signIn({
    required String identity,
    required String password,
  }) async {
    final email = identity.trim().toLowerCase();
    if (!_isValidEmail(email)) {
      throw const AuthException(
        'Vui lòng đăng nhập bằng địa chỉ email hợp lệ.',
      );
    }

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthException('Không thể tạo phiên đăng nhập.');
      }
      _currentUser = await _loadUser(user);
      return _currentUser!;
    } on supabase.AuthException catch (error) {
      throw AuthException(_friendlyMessage(error.message));
    }
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
    return guestUser;
  }

  @override
  Future<AuthUser> register({
    required String fullName,
    required String displayName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedFullName = fullName.trim();
    final normalizedDisplayName = displayName.trim().isEmpty
        ? normalizedFullName
        : displayName.trim();

    if (!_isValidEmail(normalizedEmail)) {
      throw const AuthException('Email không đúng định dạng.');
    }
    if (password.length < 8) {
      throw const AuthException('Mật khẩu phải có ít nhất 8 ký tự.');
    }

    try {
      final response = await _client.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {
          'full_name': normalizedFullName,
          'display_name': normalizedDisplayName,
        },
      );
      final user = response.user;
      if (user == null) {
        throw const AuthException('Không thể tạo tài khoản. Vui lòng thử lại.');
      }
      if (user.identities != null && user.identities!.isEmpty) {
        throw const AuthException('Email này đã được sử dụng.');
      }

      final mappedUser = _mapUser(user, role: UserRole.user);
      _currentUser = response.session == null ? null : mappedUser;
      return mappedUser;
    } on supabase.AuthException catch (error) {
      throw AuthException(_friendlyMessage(error.message));
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!_isValidEmail(normalizedEmail)) {
      throw const AuthException('Email không đúng định dạng.');
    }
    try {
      await _client.auth.resetPasswordForEmail(normalizedEmail);
    } on supabase.AuthException catch (error) {
      throw AuthException(_friendlyMessage(error.message));
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.length < 8) {
      throw const AuthException('Mật khẩu mới phải có ít nhất 8 ký tự.');
    }
    final email = _client.auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      throw const AuthException('Bạn chưa đăng nhập bằng địa chỉ email.');
    }
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
      await _client.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
    } on supabase.AuthException catch (error) {
      throw AuthException(_friendlyMessage(error.message));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _currentUser = null;
    } on supabase.AuthException catch (error) {
      throw AuthException(_friendlyMessage(error.message));
    }
  }

  Future<AuthUser> _loadUser(supabase.User user) async {
    var role = UserRole.user;
    try {
      final isAdmin = await _client.rpc('is_admin');
      if (isAdmin == true) role = UserRole.admin;
    } catch (_) {
      // Authentication remains usable if optional profile data is unavailable.
      // The backend still enforces every admin operation with RLS.
    }
    return _mapUser(user, role: role);
  }

  AuthUser _mapUser(supabase.User user, {required UserRole role}) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final displayName = (metadata['display_name'] as String?)?.trim();
    final fullName = (metadata['full_name'] as String?)?.trim();
    final email = user.email ?? '';
    return AuthUser(
      id: user.id,
      usernameOrEmail: email,
      displayName: displayName?.isNotEmpty == true
          ? displayName!
          : fullName?.isNotEmpty == true
          ? fullName!
          : email.split('@').first,
      role: role,
    );
  }

  bool _isValidEmail(String value) {
    final at = value.indexOf('@');
    return at > 0 && at < value.length - 3 && value.indexOf('.', at) > at + 1;
  }

  String _friendlyMessage(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('invalid login credentials')) {
      return 'Email hoặc mật khẩu không chính xác.';
    }
    if (normalized.contains('email not confirmed')) {
      return 'Bạn cần xác minh email trước khi đăng nhập.';
    }
    if (normalized.contains('already registered') ||
        normalized.contains('already been registered')) {
      return 'Email này đã được sử dụng.';
    }
    if (normalized.contains('password')) {
      return 'Mật khẩu chưa đáp ứng yêu cầu bảo mật.';
    }
    if (normalized.contains('rate limit')) {
      return 'Bạn thao tác quá nhanh. Vui lòng thử lại sau.';
    }
    return 'Không thể xác thực lúc này. Vui lòng thử lại.';
  }
}

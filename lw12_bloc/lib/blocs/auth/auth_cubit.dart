import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  static const Map<String, String> _users = {
    'S23067477@narxoz.kz': 'Tangyt Zhibek',
    'student@narxoz.kz': 'Narxoz Student',
  };
  static const String _validPassword = 'Zhibek11';

  Future<void> login(String email, String password) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty || password.isEmpty) {
      emit(const AuthError('Email and password must not be empty'));
      return;
    }

    emit(const AuthLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (isClosed) return; 

      final username = _users[cleanEmail];
      if (username != null && password == _validPassword) {
        emit(AuthSuccess(username: username, email: cleanEmail));
      } else {
        emit(const AuthError('Invalid credentials! Hint: student@narxoz.kz / 123456'));
      }
    } catch (e) {
      if (!isClosed) emit(AuthError(e.toString()));
    }
  }

  void logout() {
    emit(const AuthInitial());
  }
}

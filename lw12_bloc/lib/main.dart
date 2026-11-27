import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_cubit.dart';
import 'blocs/cart/cart_bloc.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const NarxozEnterpriseApp());
}

class NarxozEnterpriseApp extends StatelessWidget {
  const NarxozEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<CartBloc>(create: (_) => CartBloc()),
      ],
      child: MaterialApp(
        title: 'Narxoz Enterprise BLoC App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF02569B)),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

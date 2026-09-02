import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/features/auth/bloc/get_me_cubit.dart';
import 'package:data_portal_survey/features/auth/bloc/logout_cubit.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

class MultiBlocWrapper extends StatelessWidget {
  final Widget child;

  const MultiBlocWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LogoutCubit(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          ),
          lazy: true,
        ),
        BlocProvider(
          create: (context) => GetMeCubit(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          ),
          lazy: true,
        ),
      ],
      child: child,
    );
  }
}

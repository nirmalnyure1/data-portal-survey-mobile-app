// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/features/auth/model/user_model.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

// use for listen user data (value notifier is used)
class UserListenerModel {
  final UserModel? userModel;
  final bool isLoggedIn;
  final String? loyaltyBalance;
  UserListenerModel({
    this.userModel,
    required this.isLoggedIn,
    this.loyaltyBalance,
  });
}

typedef UserListenableBuilder =
    Widget Function(BuildContext, UserListenerModel);

class UserListener extends StatelessWidget {
  const UserListener({super.key, required this.builder});
  final UserListenableBuilder builder;

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryProvider.of<AuthRepository>(context);

    return AnimatedBuilder(
      animation: Listenable.merge([
        repo.user,
        repo.isLoggedIn,
        repo.loyaltyBalance,
      ]),
      builder: (context, child) {
        return builder(
          context,
          UserListenerModel(
            isLoggedIn: repo.isLoggedIn.value,
            userModel: repo.user.value,
            loyaltyBalance: repo.loyaltyBalance.value,
          ),
        );
      },
    );
  }
}

// typedef UserLoggedInListenableBuilder = Widget Function(BuildContext, bool);

// class UserLoggedInListener extends StatelessWidget {
//   const UserLoggedInListener({super.key, required this.builder});
//   final UserLoggedInListenableBuilder builder;

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: getIt<AuthRepository>().isLoggedIn,
//       builder: (context, isLoggedIn, child) => builder(context, isLoggedIn),
//     );
//   }
// }

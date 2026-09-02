import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/features/profile/bloc/profile_cubit.dart';
import 'package:data_portal_survey/features/profile/ui/widget/edit_profile_widget.dart';

@RoutePage()
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RepositoryProvider.of<ProfileCubit>(context),
      child: EditProfileWidget(),
    );
  }
}

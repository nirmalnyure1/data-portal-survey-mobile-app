import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/utils/card_boxshadow_utils.dart';
import 'package:data_portal_survey/common/utils/media_picker.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/common/widgets/custom_multiline_text_field.dart';
import 'package:data_portal_survey/common/widgets/issue_item_widget.dart';
import 'package:data_portal_survey/common/widgets/page_wrapper.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/features/support/cubit/support_cubit.dart';
import 'package:data_portal_survey/features/support/model/support_ticket_result.dart';
import 'package:data_portal_survey/features/support/resource/support_repository.dart';
import 'package:data_portal_survey/navigation/app_router.dart';

const _issueTypes = <String>[
  'Missing Item',
  'Wrong Item',
  'Quality Issue',
  'Late Delivery',
  'Other',
];

@RoutePage()
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _selectedIndex;
  final _descriptionController = TextEditingController();
  File? _imageFile;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: AppInsets.all16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take photo'),
                  onTap: () async {
                    final file = await MediaPicker.pickImageFromCamera();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    if (file == null) return;
                    setState(() => _imageFile = File(file.path));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () async {
                    final file = await MediaPicker.pickImageFromGallery();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    if (file == null) return;
                    setState(() => _imageFile = File(file.path));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    if (_selectedIndex == null) {
      ToastMessageUtils.warning('Please select an issue type');
      return;
    }
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ToastMessageUtils.warning('Please describe your issue');
      return;
    }

    context.read<SupportCubit>().submit(
      issueType: _issueTypes[_selectedIndex!],
      description: description,
      imageFile: _imageFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SupportCubit(supportRepository: context.read<SupportRepository>()),
      child: BlocConsumer<SupportCubit, CommonState>(
        listener: (context, state) {
          if (state is CommonError) {
            ToastMessageUtils.error(state.message);
          }
          if (state is CommonStateSuccess<SupportTicketResult>) {
            context.router.replace(
              SupportTicketSuccessRoute(
                ticketDisplay: state.data.ticketDisplay,
              ),
            );
          }
        },
        builder: (context, state) {
          final loading = state is CommonLoading;
          return PageWrapper(
            title: 'Help & Support',
            // appBarToolbarHeight: AppSpacing.s60,
            // appBarLeadingBackgroundColor: ThemeColors.lightGrey,
            body: SingleChildScrollView(
              clipBehavior: Clip.none,
              padding: const EdgeInsets.only(bottom: AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: AppInsets.all14,
                    decoration: BoxDecoration(
                      color: ThemeColors.cardBackGroundColor,
                      borderRadius: AppShapes.radiusLg,
                      boxShadow: [CardBoxShadowUtils.cardBoxShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Issue Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.black,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        for (var i = 0; i < _issueTypes.length; i++)
                          IssueItemWidget(
                            label: _issueTypes[i],
                            selected: _selectedIndex == i,
                            onTap: () => setState(() => _selectedIndex = i),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s18),
                  Container(
                    padding: AppInsets.all16,
                    decoration: BoxDecoration(
                      color: ThemeColors.cardBackGroundColor,
                      borderRadius: AppShapes.radiusLg,
                      boxShadow: [CardBoxShadowUtils.cardBoxShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Describe Issue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.black,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s10),
                        CustomMultilineTextField(
                          controller: _descriptionController,
                          hintText: 'Write here...',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s18),
                  Container(
                    decoration: BoxDecoration(
                      color: ThemeColors.cardBackGroundColor,
                      borderRadius: AppShapes.radiusLg,
                      boxShadow: [CardBoxShadowUtils.cardBoxShadow],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: AppShapes.radiusLg,
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: AppShapes.radiusLg,
                        child: SizedBox(
                          height: AppSpacing.s50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                color: ThemeColors.primaryColor,
                                size: AppSpacing.s22,
                              ),
                              const SizedBox(width: AppSpacing.s10),
                              Text(
                                _imageFile == null
                                    ? 'Attach Image (Optional)'
                                    : 'Image attached — tap to change',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  SizedBox(
                    height: AppSpacing.s56,
                    child: PrimaryButton(
                      text: 'Submit Request',
                      isLoading: loading,
                      onPressed: () => _submit(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

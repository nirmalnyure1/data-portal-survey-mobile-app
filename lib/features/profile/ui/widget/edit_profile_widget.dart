import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/common/storage/secure_storage.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/utils/media_picker.dart';
import 'package:data_portal_survey/common/widgets/page_wrapper.dart';
import 'package:data_portal_survey/features/auth/bloc/contact_verify_cubit.dart';
import 'package:data_portal_survey/features/auth/model/user_model.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/auth/ui/widget/contact_verify_otp_sheet.dart';
import 'package:data_portal_survey/features/auth/ui/widget/date_picker_sheet.dart';
import 'package:data_portal_survey/features/profile/bloc/profile_cubit.dart';
import 'package:data_portal_survey/features/profile/resource/profile_repository.dart';
import 'package:data_portal_survey/features/profile/ui/widget/contact_verify_action.dart';
import 'package:data_portal_survey/features/auth/ui/widget/auth_text_field.dart';
import 'package:data_portal_survey/features/auth/ui/widget/auth_labeled_field.dart';
import 'package:data_portal_survey/features/auth/ui/widget/phone_number_field.dart';
import 'package:data_portal_survey/common/utils/form_validator.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _referralCodeController;

  DateTime? _selectedDob;
  File? _selectedImage;
  String _dialCode = '+977';
  ContactVerifyChannel? _pendingVerifyChannel;
  String _pendingVerifyDestination = '';
  bool _otpSheetOpen = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthRepository>().user.value;
    _fullNameController = TextEditingController(
      text:
          '${user?.firstName ?? ''}${(user?.lastName ?? '').isNotEmpty ? ' ${user?.lastName}' : ''}',
    );
    _emailController = TextEditingController(text: user?.email ?? '');
    final phone = user?.phone ?? '';
    if (phone.startsWith('+91')) {
      _dialCode = '+91';
      _phoneController = TextEditingController(text: phone.substring(3));
    } else if (phone.startsWith('+977')) {
      _dialCode = '+977';
      _phoneController = TextEditingController(text: phone.substring(4));
    } else {
      _phoneController = TextEditingController(text: phone);
    }
    _phoneController.addListener(_onContactChanged);
    _emailController.addListener(_onContactChanged);
    _dateOfBirthController = TextEditingController();
    _referralCodeController = TextEditingController();

    final dob = user?.dateOfBirth;
    if (dob != null) {
      _selectedDob = dob;
      _dateOfBirthController.text = _formatDateForDisplay(dob);
    }

    // Fresh flags from server — cached user can be stale / incomplete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserFromServer();
    });
  }

  void _onContactChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshUserFromServer() async {
    final res = await context.read<AuthRepository>().getMe();
    if (!mounted) return;
    if (res.data != null) {
      setState(() => _syncContactFieldsFromUser(res.data));
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onContactChanged);
    _emailController.removeListener(_onContactChanged);
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  String _normalizedPhone() {
    final raw = _phoneController.text.trim();
    if (raw.startsWith('+')) return raw;
    final digits = FormValidator.digitsOnly(raw);
    if (digits.isEmpty) return '';
    return '$_dialCode$digits';
  }

  Future<void> _showImageSourceSheet() async {
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
                    setState(() {
                      _selectedImage = File(file.path);
                    });
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
                    setState(() {
                      _selectedImage = File(file.path);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DatePickerSheet(
          initialDate: _selectedDob ?? DateTime.now(),
          title: 'Select Date of Birth',
          onDateSelected: (DateTime selectedDate) {
            setState(() {
              _selectedDob = selectedDate;
              _dateOfBirthController.text = _formatDateForDisplay(selectedDate);
            });
          },
        );
      },
    );
  }

  String _formatDateForDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _syncContactFieldsFromUser(UserModel? user) {
    if (user == null) return;
    _emailController.text = user.email ?? '';
    final phone = user.phone;
    if (phone.startsWith('+91')) {
      _dialCode = '+91';
      _phoneController.text = phone.substring(3);
    } else if (phone.startsWith('+977')) {
      _dialCode = '+977';
      _phoneController.text = phone.substring(4);
    } else {
      _phoneController.text = phone;
    }
  }

  Future<void> _openOtpSheet({
    required BuildContext context,
    required ContactVerifyChannel channel,
    required String destination,
  }) async {
    setState(() => _otpSheetOpen = true);
    final verified = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ContactVerifyCubit>(),
        child: ContactVerifyOtpSheet(
          channel: channel,
          destination: destination,
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _otpSheetOpen = false);
    if (verified == true) {
      setState(() {
        _syncContactFieldsFromUser(context.read<AuthRepository>().user.value);
      });
    }
  }

  void _startPhoneVerification(BuildContext context) {
    final phoneError = FormValidator.phoneNumber(_phoneController.text);
    if (phoneError != null) {
      ToastMessageUtils.warning(phoneError);
      return;
    }
    final phone = _normalizedPhone();
    _pendingVerifyChannel = ContactVerifyChannel.phone;
    _pendingVerifyDestination = phone;
    context.read<ContactVerifyCubit>().startPhoneVerification(phone: phone);
  }

  void _startEmailVerification(BuildContext context) {
    final email = _emailController.text.trim();
    final emailError = FormValidator.emailOptional(email);
    if (email.isEmpty) {
      ToastMessageUtils.warning('Please enter an email address');
      return;
    }
    if (emailError != null) {
      ToastMessageUtils.warning(emailError);
      return;
    }
    _pendingVerifyChannel = ContactVerifyChannel.email;
    _pendingVerifyDestination = email;
    context.read<ContactVerifyCubit>().startEmailVerification(email: email);
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = context.read<AuthRepository>().user.value;
    final email = _emailController.text.trim();

    final payload = <String, dynamic>{
      'firstName': () {
        final full = _fullNameController.text.trim();
        if (full.isEmpty) return '';
        final parts = full.split(RegExp(r'\s+'));
        return parts.isNotEmpty ? parts.first : full;
      }(),
      'lastName': () {
        final full = _fullNameController.text.trim();
        final parts = full.split(RegExp(r'\s+'));
        if (parts.length <= 1) return '';
        return parts.sublist(1).join(' ');
      }(),
    };

    // Phone / unverified email are handled only via the Verify action + OTP.
    if (user != null &&
        user.hasVerifiedEmail &&
        email.isNotEmpty &&
        email == (user.email ?? '')) {
      payload['email'] = email;
    }

    if (_dateOfBirthController.text.isNotEmpty && _selectedDob != null) {
      payload['dateOfBirth'] = _formatDate(_selectedDob!);
    }

    await context.read<ProfileCubit>().updateProfile(
      payload: payload,
      imageFile: _selectedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = RepositoryProvider.of<AuthRepository>(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileCubit(
            profileRepository: RepositoryProvider.of<ProfileRepository>(
              context,
            ),
            authRepository: authRepository,
            secureStorage: RepositoryProvider.of<SecureStorage>(context),
          ),
        ),
        BlocProvider(
          create: (context) =>
              ContactVerifyCubit(authRepository: authRepository),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ProfileCubit, CommonState>(
            listener: (context, state) {
              if (state is CommonError) {
                ToastMessageUtils.error(state.message);
              }

              if (state is CommonStateSuccess<UserModel>) {
                ToastMessageUtils.success('Profile updated successfully');
                Navigator.of(context).pop();
              }
            },
          ),
          BlocListener<ContactVerifyCubit, CommonState>(
            listener: (context, state) {
              if (state is CommonStateSuccess<ContactVerifyChannel>) {
                final channel = _pendingVerifyChannel ?? state.data;
                final destination = _pendingVerifyDestination.isNotEmpty
                    ? _pendingVerifyDestination
                    : channel == ContactVerifyChannel.phone
                    ? _normalizedPhone()
                    : _emailController.text.trim();
                _openOtpSheet(
                  context: context,
                  channel: channel,
                  destination: destination,
                );
              }
              if (state is CommonError) {
                ToastMessageUtils.error(state.message);
              }
            },
          ),
        ],
        child: ValueListenableBuilder<UserModel?>(
          valueListenable: authRepository.user,
          builder: (context, user, _) {
            final profilePicture = user?.profilePicture ?? '';
            final hasRemoteImage = profilePicture.isNotEmpty;
            final ImageProvider? avatarImage = _selectedImage != null
                ? FileImage(_selectedImage!)
                : hasRemoteImage
                ? NetworkImage(profilePicture)
                : null;

            final phoneVerified = user?.hasVerifiedPhone == true;
            final emailVerified = user?.hasVerifiedEmail == true;
            final normalizedPhone = _normalizedPhone();
            final emailText = _emailController.text.trim();

            return BlocBuilder<ProfileCubit, CommonState>(
              builder: (context, state) {
                final isLoading = state is CommonLoading;
                final verifyState = context.watch<ContactVerifyCubit>().state;
                // Only block the profile page while starting verify (before OTP sheet).
                // OTP sheet loading must not also dim/load this page.
                final isStartingVerify =
                    !_otpSheetOpen && verifyState is CommonLoading;

                return PageWrapper(
                  title: 'Profile',
                  body: AbsorbPointer(
                    absorbing: isStartingVerify,
                    child: Opacity(
                      opacity: isStartingVerify ? 0.6 : 1,
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: GestureDetector(
                                  onTap: _showImageSourceSheet,
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: AppSpacing.s64,
                                        backgroundColor:
                                            ThemeColors.primaryColor,
                                        backgroundImage: avatarImage,
                                        child:
                                            _selectedImage == null &&
                                                !hasRemoteImage
                                            ? const Icon(
                                                Icons.person,
                                                color: ThemeColors
                                                    .pageBackGroundColor,
                                                size: AppSpacing.s64,
                                              )
                                            : null,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: ThemeColors.primaryColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                ThemeColors.pageBackGroundColor,
                                            width: 2,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color:
                                              ThemeColors.pageBackGroundColor,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s20),
                              AuthLabeledField(
                                label: 'Full Name',
                                field: AuthTextField(
                                  controller: _fullNameController,
                                  hintText: 'First Last',
                                  validator: FormValidator.fullName,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              AuthLabeledField(
                                label: 'Phone Number',
                                field: PhoneNumberField(
                                  controller: _phoneController,
                                  initialDialCode: _dialCode,
                                  hintText: '+977 98xxxxxxxx',
                                  enabled: !phoneVerified,
                                  validator: phoneVerified
                                      ? null
                                      : FormValidator.phoneNumber,
                                  onDialCodeChanged: phoneVerified
                                      ? null
                                      : (code) {
                                          setState(() => _dialCode = code);
                                        },
                                ),
                              ),
                              ContactVerifyAction(
                                verified: phoneVerified,
                                canVerify:
                                    !phoneVerified &&
                                    normalizedPhone.isNotEmpty,
                                busy: isStartingVerify,
                                onVerify: () =>
                                    _startPhoneVerification(context),
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              AuthLabeledField(
                                label: 'Email Address',
                                field: AuthTextField(
                                  controller: _emailController,
                                  hintText: 'example@gmail.com',
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !emailVerified,
                                  validator: FormValidator.emailOptional,
                                ),
                              ),
                              ContactVerifyAction(
                                verified: emailVerified,
                                canVerify:
                                    !emailVerified && emailText.isNotEmpty,
                                busy: isStartingVerify,
                                onVerify: () =>
                                    _startEmailVerification(context),
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              AuthLabeledField(
                                label: 'Date of Birth',
                                field: GestureDetector(
                                  onTap: _showDatePicker,
                                  child: AbsorbPointer(
                                    child: AuthTextField(
                                      controller: _dateOfBirthController,
                                      hintText: 'DD/MM/YYYY',
                                      enabled: false,
                                      suffix: const Icon(
                                        Icons.calendar_today_outlined,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s24),
                              SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  text: 'Update Profile',
                                  onPressed: isLoading || isStartingVerify
                                      ? null
                                      : () => _submit(context),
                                  isLoading: isLoading,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

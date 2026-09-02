import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/utils/media_picker.dart';
import 'package:data_portal_survey/features/survey/bloc/household_survey_cubit.dart';
import 'package:data_portal_survey/features/survey/bloc/household_survey_state.dart';
import 'package:data_portal_survey/features/survey/constants/household_survey_strings.dart';
import 'package:data_portal_survey/features/survey/constants/survey_strings.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';
import 'package:data_portal_survey/features/survey/model/household_survey_models.dart';
import 'package:data_portal_survey/features/survey/ui/widget/survey_form_widgets.dart';
import 'package:data_portal_survey/features/survey/utils/household_survey_validation.dart';

String? _errorMessage(SurveyLang lang, String? code) {
  if (code == null) return null;
  if (code == 'required') return HouseholdSurveyStrings.requiredError(lang);
  if (code == 'invalid') return HouseholdSurveyStrings.invalidError(lang);
  return null;
}

class SurveyStepTitle extends StatelessWidget {
  const SurveyStepTitle({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: SurveyTheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13.5,
            color: SurveyTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}

class BasicInfoStep extends StatelessWidget {
  const BasicInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HouseholdSurveyCubit, HouseholdSurveyState>(
      builder: (context, state) {
        final cubit = context.read<HouseholdSurveyCubit>();
        final lang = cubit.lang;
        final answers = state.draft.answers;
        final showErr = cubit.showErrorsForStep(0);
        final errors = showErr
            ? HouseholdSurveyValidation.validateStep(state.draft, 0)
            : {};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurveyStepTitle(
              title: HouseholdSurveyStrings.stepTitles(lang)[0],
              subtitle: SurveyStrings.tr(
                lang,
                'Basic household identification and contact details.',
                'आधारभूत घरधुरी परिचय र सम्पर्क विवरण।',
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(lang, 'Household head name', 'घरमूलीको नाम'),
              required: true,
              errorText: _errorMessage(lang, errors['headName']),
              child: SurveyTextField(
                initialValue: answers.headName,
                onChanged: (v) => cubit.updateAnswerField(headName: v),
                placeholder: SurveyStrings.tr(
                  lang,
                  'e.g. Ram Bahadur Thapa',
                  'जस्तै रामबहादुर थापा',
                ),
                hasError: showErr && errors.containsKey('headName'),
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(lang, 'Phone number', 'फोन नम्बर'),
              required: true,
              errorText: _errorMessage(lang, errors['phone']),
              child: SurveyTextField(
                initialValue: answers.phone,
                keyboardType: TextInputType.phone,
                onChanged: (v) => cubit.updateAnswerField(
                  phone: v.replaceAll(RegExp(r'[^0-9]'), ''),
                ),
                placeholder: '98XXXXXXXX',
                hasError: showErr && errors.containsKey('phone'),
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(lang, 'Email (optional)', 'इमेल (वैकल्पिक)'),
              child: SurveyTextField(
                initialValue: answers.email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) => cubit.updateAnswerField(email: v),
                placeholder: 'name@example.com',
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(lang, 'Ward number', 'वडा नम्बर'),
              required: true,
              errorText: _errorMessage(lang, errors['wardNumber']),
              child: SurveyTextField(
                initialValue: answers.wardNumber,
                keyboardType: TextInputType.number,
                onChanged: (v) => cubit.updateAnswerField(wardNumber: v),
                placeholder: SurveyStrings.tr(lang, 'e.g. 5', 'जस्तै ५'),
                hasError: showErr && errors.containsKey('wardNumber'),
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(lang, 'Full address', 'पूरा ठेगाना'),
              required: true,
              errorText: _errorMessage(lang, errors['address']),
              child: SurveyTextField(
                initialValue: answers.address,
                maxLines: 3,
                onChanged: (v) => cubit.updateAnswerField(address: v),
                placeholder: SurveyStrings.tr(
                  lang,
                  'Municipality, ward, tole',
                  'नगरपालिका, वडा, टोल',
                ),
                hasError: showErr && errors.containsKey('address'),
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(
                lang,
                'Tole / landmark (optional)',
                'टोल / ठाडो चिनो (वैकल्पिक)',
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SurveyTextField(
                      initialValue: answers.toleLocation,
                      onChanged: (v) => cubit.updateAnswerField(toleLocation: v),
                      placeholder: SurveyStrings.tr(
                        lang,
                        'Nearest landmark',
                        'नजिकको चिनो',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => cubit.captureGpsLocation(),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: SurveyTheme.surfaceLowest,
                        borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
                        border: Border.all(color: SurveyTheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: SurveyTheme.primary, width: 2),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            SurveyStrings.tr(lang, 'Use GPS', 'GPS प्रयोग'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: SurveyTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class HouseholdHeadStep extends StatelessWidget {
  const HouseholdHeadStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HouseholdSurveyCubit, HouseholdSurveyState>(
      builder: (context, state) {
        final cubit = context.read<HouseholdSurveyCubit>();
        final lang = cubit.lang;
        final answers = state.draft.answers;
        final showErr = cubit.showErrorsForStep(1);
        final errors = showErr
            ? HouseholdSurveyValidation.validateStep(state.draft, 1)
            : {};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurveyStepTitle(
              title: HouseholdSurveyStrings.stepTitles(lang)[1],
              subtitle: SurveyStrings.tr(
                lang,
                'Head of household details and land ownership.',
                'घरमूलीको विवरण र जमिन स्वामित्व।',
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(lang, 'Date of birth', 'जन्म मिति'),
              required: true,
              hint: SurveyStrings.tr(
                lang,
                'Stored as AD date internally.',
                'आन्तरिक रूपमा ईसाई मितिको रूपमा भण्डारण गरिन्छ।',
              ),
              errorText: _errorMessage(lang, errors['dob']),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: SurveyTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          children: [
                            SurveyLangPill(
                              label: 'AD',
                              small: true,
                              selected: answers.calendarType != 'bs',
                              onTap: () => cubit.updateAnswerField(calendarType: 'ad'),
                            ),
                            SurveyLangPill(
                              label: 'BS',
                              small: true,
                              selected: answers.calendarType == 'bs',
                              onTap: () => cubit.updateAnswerField(calendarType: 'bs'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (answers.calendarType != 'bs')
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(1900),
                          lastDate: now,
                        );
                        if (picked != null) {
                          cubit.updateAnswerField(
                            dob:
                                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
                          );
                        }
                      },
                      child: SurveyTextField(
                        readOnly: true,
                        placeholder: answers.dob.isEmpty ? 'YYYY-MM-DD' : answers.dob,
                        hasError: showErr && errors.containsKey('dob'),
                      ),
                    )
                  else
                    SurveyTextField(
                      initialValue: answers.dob,
                      onChanged: (v) => cubit.updateAnswerField(dob: v),
                      placeholder: 'YYYY-MM-DD (BS)',
                      hasError: showErr && errors.containsKey('dob'),
                    ),
                ],
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(lang, 'Gender', 'लिङ्ग'),
              required: true,
              errorText: _errorMessage(lang, errors['gender']),
              child: DropdownButtonFormField<String>(
                value: answers.gender.isEmpty ? null : answers.gender,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: SurveyTheme.surfaceLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
                    borderSide: BorderSide(
                      color: showErr && errors.containsKey('gender')
                          ? SurveyTheme.errorBorder
                          : SurveyTheme.defaultBorder,
                    ),
                  ),
                ),
                hint: Text(HouseholdSurveyStrings.selectPh(lang)),
                items: HouseholdSurveyStrings.genderOptions(lang)
                    .map(
                      (o) => DropdownMenuItem(value: o.value, child: Text(o.label)),
                    )
                    .toList(),
                onChanged: (v) => cubit.updateAnswerField(gender: v ?? ''),
              ),
            ),
            SurveyCard(
              tinted: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${SurveyStrings.tr(lang, 'Does this household own agricultural land?', 'यो घरधुरीले कृषि जमिन स्वामित्व राख्छ?')} *',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SurveyChoiceButton(
                        label: HouseholdSurveyStrings.yesLabel(lang),
                        selected: answers.ownsLand == 'yes',
                        onTap: () => cubit.updateAnswerField(ownsLand: 'yes'),
                      ),
                      const SizedBox(width: 10),
                      SurveyChoiceButton(
                        label: HouseholdSurveyStrings.noLabel(lang),
                        selected: answers.ownsLand == 'no',
                        onTap: () => cubit.updateAnswerField(ownsLand: 'no', landArea: ''),
                      ),
                    ],
                  ),
                  if (showErr && errors.containsKey('ownsLand'))
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _errorMessage(lang, errors['ownsLand'])!,
                        style: const TextStyle(color: SurveyTheme.secondary, fontSize: 12.5),
                      ),
                    ),
                  if (answers.ownsLand == 'yes') ...[
                    const SizedBox(height: 16),
                    SurveyFormField(
                      label: SurveyStrings.tr(
                        lang,
                        'Land area (ropani)',
                        'जमिनको क्षेत्रफल (रोपनी)',
                      ),
                      required: true,
                      errorText: _errorMessage(lang, errors['landArea']),
                      child: SurveyTextField(
                        initialValue: answers.landArea,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (v) => cubit.updateAnswerField(landArea: v),
                        placeholder: '0.0',
                        hasError: showErr && errors.containsKey('landArea'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class MembersStep extends StatelessWidget {
  const MembersStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HouseholdSurveyCubit, HouseholdSurveyState>(
      builder: (context, state) {
        final cubit = context.read<HouseholdSurveyCubit>();
        final lang = cubit.lang;
        final members = state.draft.members;
        final showErr = cubit.showErrorsForStep(2);
        final errors = showErr
            ? HouseholdSurveyValidation.validateStep(state.draft, 2)
            : {};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurveyStepTitle(
              title: HouseholdSurveyStrings.stepTitles(lang)[2],
              subtitle: SurveyStrings.tr(
                lang,
                'Add every person living in this household.',
                'यो घरधुरीमा बस्ने प्रत्येक व्यक्ति थप्नुहोस्।',
              ),
            ),
            ...members.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              return SurveyCard(
                title: '${SurveyStrings.tr(lang, 'Member', 'सदस्य')} ${i + 1}',
                trailing: members.length > 1
                    ? GestureDetector(
                        onTap: () => cubit.removeMember(m.id),
                        child: Text(
                          SurveyStrings.tr(lang, 'Remove', 'हटाउनुहोस्'),
                          style: const TextStyle(
                            color: SurveyTheme.secondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SurveyFormField(
                            label: SurveyStrings.tr(lang, 'Full name', 'पूरा नाम'),
                            required: true,
                            errorText: _errorMessage(lang, errors['member_${i}_name']),
                            child: SurveyTextField(
                              initialValue: m.name,
                              onChanged: (v) =>
                                  cubit.updateMember(m.id, m.copyWith(name: v)),
                              hasError: showErr && errors.containsKey('member_${i}_name'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: SurveyFormField(
                            label: SurveyStrings.tr(lang, 'Age', 'उमेर'),
                            required: true,
                            errorText: _errorMessage(lang, errors['member_${i}_age']),
                            child: SurveyTextField(
                              initialValue: m.age,
                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                                  cubit.updateMember(m.id, m.copyWith(age: v)),
                              hasError: showErr && errors.containsKey('member_${i}_age'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SurveyFormField(
                      label: SurveyStrings.tr(
                        lang,
                        'Relation to head',
                        'घरमूलीसँगको सम्बन्ध',
                      ),
                      child: DropdownButtonFormField<String>(
                        value: m.relation.isEmpty ? null : m.relation,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: SurveyTheme.surfaceLowest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
                          ),
                        ),
                        hint: Text(HouseholdSurveyStrings.selectPh(lang)),
                        items: HouseholdSurveyStrings.relationOptions(lang)
                            .map(
                              (o) =>
                                  DropdownMenuItem(value: o.value, child: Text(o.label)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            cubit.updateMember(m.id, m.copyWith(relation: v ?? '')),
                      ),
                    ),
                    Text(
                      SurveyStrings.tr(
                        lang,
                        'Skills / occupation',
                        'सीप / पेशा',
                      ),
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: HouseholdSurveyStrings.skillsList(lang).map((s) {
                        final active = m.skills.contains(s.key);
                        return GestureDetector(
                          onTap: () => cubit.toggleMemberSkill(m.id, s.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? SurveyTheme.primarySoft
                                  : SurveyTheme.surfaceLowest,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: active
                                    ? SurveyTheme.primary
                                    : SurveyTheme.defaultBorder,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              s.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? SurveyTheme.primary
                                    : SurveyTheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
            if (members.length < HouseholdSurveyDraft.maxMembers)
              GestureDetector(
                onTap: () => cubit.addMember(),
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
                    border: Border.all(
                      color: SurveyTheme.outlineVariant,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Text(
                    SurveyStrings.tr(
                      lang,
                      '+ Add household member',
                      '+ घरपरिवार सदस्य थप्नुहोस्',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: SurveyTheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class CropsStep extends StatelessWidget {
  const CropsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HouseholdSurveyCubit, HouseholdSurveyState>(
      builder: (context, state) {
        final cubit = context.read<HouseholdSurveyCubit>();
        final lang = cubit.lang;
        final showErr = cubit.showErrorsForStep(3);
        final errors = showErr
            ? HouseholdSurveyValidation.validateStep(state.draft, 3)
            : {};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurveyStepTitle(
              title: HouseholdSurveyStrings.stepTitles(lang)[3],
              subtitle: SurveyStrings.tr(
                lang,
                'Tell us about crops grown this season.',
                'यस सिजनमा उब्जाइने बालीहरूको बारेमा बताउनुहोस्।',
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(
                lang,
                'How many types of crops do you grow?',
                'तपाईं कति प्रकारका बाली उब्जाउनुहुन्छ?',
              ),
              required: true,
              errorText: _errorMessage(lang, errors['cropCount']),
              child: SurveyTextField(
                initialValue: state.draft.cropCount == 0 ? '' : '${state.draft.cropCount}',
                keyboardType: TextInputType.number,
                onChanged: (v) => cubit.setCropCount(int.tryParse(v) ?? 0),
                hasError: showErr && errors.containsKey('cropCount'),
              ),
            ),
            ...state.draft.crops.asMap().entries.map((entry) {
              final i = entry.key;
              final crop = entry.value;
              return SurveyCard(
                title: '${SurveyStrings.tr(lang, 'Crop', 'बाली')} ${i + 1}',
                child: Column(
                  children: [
                    SurveyFormField(
                      label: SurveyStrings.tr(
                        lang,
                        'Crop type',
                        'बालीको प्रकार',
                      ),
                      required: true,
                      errorText: _errorMessage(lang, errors['crop_${i}_type']),
                      child: DropdownButtonFormField<String>(
                        value: crop.type.isEmpty ? null : crop.type,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: SurveyTheme.surfaceLowest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
                            borderSide: BorderSide(
                              color: showErr && errors.containsKey('crop_${i}_type')
                                  ? SurveyTheme.errorBorder
                                  : SurveyTheme.defaultBorder,
                            ),
                          ),
                        ),
                        hint: Text(HouseholdSurveyStrings.selectPh(lang)),
                        items: HouseholdSurveyStrings.cropOptions(lang)
                            .map(
                              (o) =>
                                  DropdownMenuItem(value: o.value, child: Text(o.label)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            cubit.updateCrop(i, crop.copyWith(type: v ?? '')),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          SurveyStrings.tr(
                            lang,
                            'Share of land',
                            'जमिनको हिस्सा',
                          ),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${crop.share}%',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: SurveyTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: crop.share.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      activeColor: SurveyTheme.primary,
                      onChanged: (v) =>
                          cubit.updateCrop(i, crop.copyWith(share: v.round())),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class LivelihoodStep extends StatelessWidget {
  const LivelihoodStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HouseholdSurveyCubit, HouseholdSurveyState>(
      builder: (context, state) {
        final cubit = context.read<HouseholdSurveyCubit>();
        final lang = cubit.lang;
        final answers = state.draft.answers;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurveyStepTitle(
              title: HouseholdSurveyStrings.stepTitles(lang)[4],
              subtitle: SurveyStrings.tr(
                lang,
                'Income, satisfaction, and extension worker visits.',
                'आम्दानी, सन्तुष्टि, र प्रसार कार्यकर्ताको भ्रमण।',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  SurveyStrings.tr(
                    lang,
                    'Estimated monthly income',
                    'अनुमानित मासिक आम्दानी',
                  ),
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Rs ${answers.incomeRange}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SurveyTheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: answers.incomeRange.toDouble(),
              min: 0,
              max: 100000,
              divisions: 40,
              activeColor: SurveyTheme.primary,
              onChanged: (v) => cubit.updateAnswerField(incomeRange: v.round()),
            ),
            const SizedBox(height: 16),
            Text(
              SurveyStrings.tr(
                lang,
                'Satisfaction with agricultural support',
                'कृषि सहायताप्रति सन्तुष्टि',
              ),
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (i) {
                final star = i + 1;
                final filled = star <= answers.supportRating;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () => cubit.updateAnswerField(supportRating: star),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: SurveyTheme.surfaceLowest,
                          borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
                          border: Border.all(color: SurveyTheme.outlineVariant),
                        ),
                        child: Text(
                          filled ? '★' : '☆',
                          style: TextStyle(
                            fontSize: 20,
                            color: filled
                                ? SurveyTheme.secondary
                                : SurveyTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            SurveyFormField(
              label: SurveyStrings.tr(
                lang,
                'Last extension worker visit',
                'अन्तिम प्रसार कार्यकर्ता भ्रमण',
              ),
              child: GestureDetector(
                onTap: () async {
                  final now = DateTime.now();
                  final date = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(2000),
                    lastDate: now,
                  );
                  if (date == null) return;
                  if (!context.mounted) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(now),
                  );
                  if (time == null) return;
                  cubit.updateAnswerField(
                    lastVisitDateTime:
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  );
                },
                child: SurveyTextField(
                  readOnly: true,
                  placeholder: answers.lastVisitDateTime.isEmpty
                      ? 'Select date & time'
                      : answers.lastVisitDateTime,
                ),
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(
                lang,
                'Preferred visit time',
                'मनपर्ने भ्रमण समय',
              ),
              child: GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    cubit.updateAnswerField(
                      preferredVisitTime:
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    );
                  }
                },
                child: SurveyTextField(
                  readOnly: true,
                  placeholder: answers.preferredVisitTime.isEmpty
                      ? 'Select time'
                      : answers.preferredVisitTime,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DocumentsStep extends StatelessWidget {
  const DocumentsStep({super.key});

  Future<void> _pickFile(
    BuildContext context,
    HouseholdSurveyCubit cubit, {
    required bool housePhoto,
  }) async {
    final file = await MediaPicker.pickImageFromGallery();
    if (file == null) return;
    final ref = SurveyFileRef(name: file.name, path: file.path);
    if (housePhoto) {
      cubit.setHousePhoto(ref);
    } else {
      cubit.setLandCertificate(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HouseholdSurveyCubit, HouseholdSurveyState>(
      builder: (context, state) {
        final cubit = context.read<HouseholdSurveyCubit>();
        final lang = cubit.lang;
        final answers = state.draft.answers;
        final showErr = cubit.showErrorsForStep(5);
        final errors = showErr
            ? HouseholdSurveyValidation.validateStep(state.draft, 5)
            : {};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurveyStepTitle(
              title: HouseholdSurveyStrings.stepTitles(lang)[5],
              subtitle: SurveyStrings.tr(
                lang,
                'Upload supporting documents.',
                'सहायक कागजातहरू अपलोड गर्नुहोस्।',
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(lang, 'House photo', 'घरको फोटो'),
              required: true,
              errorText: _errorMessage(lang, errors['housePhoto']),
              child: _UploadDrop(
                label: state.draft.housePhoto?.name ??
                    SurveyStrings.tr(
                      lang,
                      'Tap to upload',
                      'अपलोड गर्न ट्याप गर्नुहोस्',
                    ),
                hasError: showErr && errors.containsKey('housePhoto'),
                onTap: () => _pickFile(context, cubit, housePhoto: true),
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(
                lang,
                'Land certificate (optional)',
                'जमिन प्रमाणपत्र (वैकल्पिक)',
              ),
              child: _UploadDrop(
                label: state.draft.landCertificate?.name ??
                    SurveyStrings.tr(
                      lang,
                      'Tap to upload',
                      'अपलोड गर्न ट्याप गर्नुहोस्',
                    ),
                onTap: () => _pickFile(context, cubit, housePhoto: false),
              ),
            ),
            SurveyFormField(
              label: SurveyStrings.tr(
                lang,
                'Reference link (optional)',
                'सन्दर्भ लिङ्क (वैकल्पिक)',
              ),
              errorText: _errorMessage(lang, errors['notesUrl']),
              child: SurveyTextField(
                initialValue: answers.notesUrl,
                keyboardType: TextInputType.url,
                onChanged: (v) => cubit.updateAnswerField(notesUrl: v),
                placeholder: 'https://...',
                hasError: showErr && errors.containsKey('notesUrl'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UploadDrop extends StatelessWidget {
  const _UploadDrop({
    required this.label,
    required this.onTap,
    this.hasError = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: SurveyTheme.surfaceLowest,
          borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
          border: Border.all(
            color: hasError ? SurveyTheme.errorBorder : SurveyTheme.outlineVariant,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: SurveyTheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.upload, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: SurveyTheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key});

  String _yn(SurveyLang lang, String v) {
    if (v == 'yes') return HouseholdSurveyStrings.yesLabel(lang);
    if (v == 'no') return HouseholdSurveyStrings.noLabel(lang);
    return '—';
  }

  String _labelFor(
    SurveyLang lang,
    List<({String value, String label})> opts,
    String v,
  ) {
    for (final o in opts) {
      if (o.value == v) return o.label;
    }
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HouseholdSurveyCubit, HouseholdSurveyState>(
      builder: (context, state) {
        final cubit = context.read<HouseholdSurveyCubit>();
        final lang = cubit.lang;
        final draft = state.draft;
        final answers = draft.answers;
        final titles = HouseholdSurveyStrings.stepTitles(lang);

        final sections = [
          (
            title: titles[0],
            step: 0,
            rows: [
              (SurveyStrings.tr(lang, 'Name', 'नाम'), answers.headName),
              (SurveyStrings.tr(lang, 'Phone', 'फोन'), answers.phone),
              (SurveyStrings.tr(lang, 'Ward', 'वडा'), answers.wardNumber),
              (SurveyStrings.tr(lang, 'Address', 'ठेगाना'), answers.address),
            ],
          ),
          (
            title: titles[1],
            step: 1,
            rows: [
              (SurveyStrings.tr(lang, 'Date of birth', 'जन्म मिति'), answers.dob),
              (
                SurveyStrings.tr(lang, 'Gender', 'लिङ्ग'),
                _labelFor(lang, HouseholdSurveyStrings.genderOptions(lang), answers.gender),
              ),
              (
                SurveyStrings.tr(lang, 'Owns land', 'जमिन स्वामित्व'),
                _yn(lang, answers.ownsLand),
              ),
            ],
          ),
          (
            title: titles[2],
            step: 2,
            rows: [
              (
                SurveyStrings.tr(lang, 'Members added', 'थपिएका सदस्य'),
                '${draft.members.length}',
              ),
            ],
          ),
          (
            title: titles[3],
            step: 3,
            rows: [
              (
                SurveyStrings.tr(lang, 'Crop types', 'बालीका प्रकार'),
                '${draft.cropCount}',
              ),
            ],
          ),
          (
            title: titles[4],
            step: 4,
            rows: [
              (
                SurveyStrings.tr(lang, 'Monthly income', 'मासिक आम्दानी'),
                'Rs ${answers.incomeRange}',
              ),
              (
                SurveyStrings.tr(lang, 'Support rating', 'सहायता मूल्याङ्कन'),
                '${answers.supportRating}/5',
              ),
            ],
          ),
          (
            title: titles[5],
            step: 5,
            rows: [
              (
                SurveyStrings.tr(lang, 'House photo', 'घरको फोटो'),
                draft.housePhoto?.name ??
                    SurveyStrings.tr(
                      lang,
                      'Not uploaded',
                      'अपलोड नभएको',
                    ),
              ),
            ],
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurveyStepTitle(
              title: titles[6],
              subtitle: SurveyStrings.tr(
                lang,
                'Please check your answers before submitting.',
                'पेश गर्नुअघि आफ्नो जवाफहरू जाँच गर्नुहोस्।',
              ),
            ),
            ...sections.map(
              (sec) => SurveyCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sec.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => cubit.editStep(sec.step),
                          child: Text(
                            SurveyStrings.tr(lang, 'Edit', 'सम्पादन'),
                            style: const TextStyle(
                              color: SurveyTheme.primary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...sec.rows.map(
                      (row) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                row.$1,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: SurveyTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Text(
                              row.$2.isEmpty ? '—' : row.$2,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

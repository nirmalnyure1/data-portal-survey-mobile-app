import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/features/survey/bloc/survey_collect_cubit.dart';
import 'package:data_portal_survey/features/survey/core/repeat.dart';
import 'package:data_portal_survey/features/survey/core/visibility.dart';
import 'package:data_portal_survey/features/survey/model/survey_form_models.dart';
import 'package:data_portal_survey/features/survey/ui/widget/survey_field_input.dart';
import 'package:data_portal_survey/features/survey/ui/widget/survey_form_widgets.dart';

class SurveySectionView extends StatelessWidget {
  const SurveySectionView({super.key, required this.section});

  final SurveySection section;

  @override
  Widget build(BuildContext context) {
    if (section.isRepeatable) {
      return _RepeatableSectionView(section: section);
    }
    return _NormalSectionView(section: section);
  }
}

class _NormalSectionView extends StatelessWidget {
  const _NormalSectionView({required this.section});

  final SurveySection section;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SurveyCollectCubit>().state;
    final split = groupRepeatFields(section.fields);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final field in split.normal)
          if (evaluateVisibility(field.visibilityRules, state.answers))
            _FieldRow(field: field, answerKey: field.id),
        for (final entry in split.groups.entries)
          _RepeatGroupView(groupId: entry.key, fields: entry.value),
      ],
    );
  }
}

class _RepeatableSectionView extends StatelessWidget {
  const _RepeatableSectionView({required this.section});

  final SurveySection section;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SurveyCollectCubit>();
    final state = context.watch<SurveyCollectCubit>().state;
    final count = state.repeatCounts[section.id] ?? section.defaultInstanceCount;
    final active = state.repeatActive[section.id] ?? 0;
    final min = section.minInstances ?? 1;
    final max = section.maxInstances ?? 99;
    final triggered = section.triggerFieldId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!triggered)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < count; i++)
                ChoiceChip(
                  label: Text('${i + 1}'),
                  selected: active == i,
                  onSelected: (_) => cubit.setRepeatActive(section.id, i),
                ),
              if (count < max)
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                  onPressed: () => cubit.addSectionInstance(section),
                ),
            ],
          ),
        if (!triggered) const SizedBox(height: 12),
        if (active < count)
          SurveyCard(
            title: 'Instance ${active + 1}',
            trailing: !triggered && count > min
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => cubit.removeSectionInstance(section, active),
                  )
                : null,
            child: _InstanceFields(
              fields: section.fields,
              instanceIndex: active,
            ),
          ),
      ],
    );
  }
}

class _RepeatGroupView extends StatelessWidget {
  const _RepeatGroupView({
    required this.groupId,
    required this.fields,
  });

  final String groupId;
  final List<SurveyField> fields;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SurveyCollectCubit>();
    final state = context.watch<SurveyCollectCubit>().state;
    final count = state.groupRepeatCounts[groupId] ?? 1;
    final active = state.groupRepeatActive[groupId] ?? 0;

    return SurveyCard(
      tinted: true,
      title: 'Repeat group',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < count; i++)
                ChoiceChip(
                  label: Text('${i + 1}'),
                  selected: active == i,
                  onSelected: (_) => cubit.setGroupRepeatActive(groupId, i),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                onPressed: () => cubit.addGroupInstance(groupId, fields),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (active < count)
            _InstanceFields(fields: fields, instanceIndex: active),
        ],
      ),
    );
  }
}

class _InstanceFields extends StatelessWidget {
  const _InstanceFields({
    required this.fields,
    required this.instanceIndex,
  });

  final List<SurveyField> fields;
  final int instanceIndex;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SurveyCollectCubit>().state;
    final ids = fields.map((f) => f.id).toList();
    final scoped = instanceScopedAnswers(state.answers, ids, instanceIndex);

    return Column(
      children: [
        for (final field in fields)
          if (evaluateVisibility(field.visibilityRules, scoped))
            _FieldRow(
              field: field,
              answerKey: repeatKey(field.id, instanceIndex),
            ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.field,
    required this.answerKey,
  });

  final SurveyField field;
  final String answerKey;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SurveyCollectCubit>();
    final state = context.watch<SurveyCollectCubit>().state;
    final locale = state.locale;

    return SurveyFormField(
      label: field.label.resolve(locale),
      required: field.isRequired,
      hint: field.helperText?.resolve(locale),
      errorText: state.fieldErrors[answerKey],
      child: SurveyFieldInput(
        field: field,
        value: state.answers[answerKey],
        locale: locale,
        error: state.fieldErrors[answerKey],
        onChanged: (v) => cubit.setAnswer(answerKey, v),
        onUploadFile: (path, filename) => cubit.uploadFile(path, filename),
      ),
    );
  }
}

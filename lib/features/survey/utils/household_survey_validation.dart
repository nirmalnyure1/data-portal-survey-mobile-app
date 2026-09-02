import 'package:data_portal_survey/features/survey/model/household_survey_models.dart';

class HouseholdSurveyValidation {
  static Map<String, String> validateStep(HouseholdSurveyDraft draft, int step) {
    final answers = draft.answers;
    final members = draft.members;
    final crops = draft.crops;
    final cropCount = draft.cropCount;
    final errors = <String, String>{};

    switch (step) {
      case 0:
        if (answers.headName.trim().isEmpty) errors['headName'] = 'required';
        if (!RegExp(r'^[0-9]{7,10}$').hasMatch(answers.phone)) {
          errors['phone'] = 'invalid';
        }
        if (answers.wardNumber.trim().isEmpty) {
          errors['wardNumber'] = 'required';
        }
        if (answers.address.trim().isEmpty) errors['address'] = 'required';
        break;
      case 1:
        if (answers.dob.trim().isEmpty) errors['dob'] = 'required';
        if (answers.gender.isEmpty) errors['gender'] = 'required';
        if (answers.ownsLand.isEmpty) errors['ownsLand'] = 'required';
        if (answers.ownsLand == 'yes' && answers.landArea.trim().isEmpty) {
          errors['landArea'] = 'required';
        }
        break;
      case 2:
        for (var i = 0; i < members.length; i++) {
          if (members[i].name.trim().isEmpty) {
            errors['member_${i}_name'] = 'required';
          }
          if (members[i].age.trim().isEmpty) {
            errors['member_${i}_age'] = 'required';
          } else {
            final age = int.tryParse(members[i].age);
            if (age == null || age < 0 || age > 120) {
              errors['member_${i}_age'] = 'invalid';
            }
          }
        }
        break;
      case 3:
        if (cropCount < 1) errors['cropCount'] = 'required';
        for (var i = 0; i < crops.length; i++) {
          if (crops[i].type.isEmpty) errors['crop_${i}_type'] = 'required';
        }
        break;
      case 4:
        break;
      case 5:
        if (draft.housePhoto == null) errors['housePhoto'] = 'required';
        if (answers.notesUrl.trim().isNotEmpty &&
            !RegExp(r'^https?:\/\/.+').hasMatch(answers.notesUrl.trim())) {
          errors['notesUrl'] = 'invalid';
        }
        break;
      case 6:
        break;
    }

    return errors;
  }

  static bool hasErrors(Map<String, String> errors) => errors.isNotEmpty;
}

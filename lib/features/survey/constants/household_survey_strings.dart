import 'package:data_portal_survey/features/survey/constants/survey_strings.dart';

class HouseholdSurveyStrings {
  const HouseholdSurveyStrings._();

  static List<String> stepTitles(SurveyLang lang) => [
        SurveyStrings.tr(lang, 'Basic Info', 'आधारभूत विवरण'),
        SurveyStrings.tr(lang, 'Household Head', 'घरमूली विवरण'),
        SurveyStrings.tr(lang, 'Household Members', 'घरपरिवार सदस्य'),
        SurveyStrings.tr(lang, 'Crops Grown', 'बाली विवरण'),
        SurveyStrings.tr(lang, 'Livelihood & Visits', 'जीविकोपार्जन र भ्रमण'),
        SurveyStrings.tr(lang, 'Documents', 'कागजातहरू'),
        SurveyStrings.tr(lang, 'Review', 'पुनरावलोकन'),
      ];

  static String requiredError(SurveyLang lang) =>
      SurveyStrings.tr(lang, 'This field is required', 'यो क्षेत्र आवश्यक छ');

  static String invalidError(SurveyLang lang) =>
      SurveyStrings.tr(lang, 'Please enter a valid value', 'मान्य मान प्रविष्ट गर्नुहोस्');

  static String yesLabel(SurveyLang lang) => SurveyStrings.tr(lang, 'Yes', 'हो');
  static String noLabel(SurveyLang lang) => SurveyStrings.tr(lang, 'No', 'होइन');
  static String selectPh(SurveyLang lang) =>
      SurveyStrings.tr(lang, 'Select…', 'चयन गर्नुहोस्…');

  static List<({String value, String label})> genderOptions(SurveyLang lang) =>
      [
        (value: 'male', label: SurveyStrings.tr(lang, 'Male', 'पुरुष')),
        (value: 'female', label: SurveyStrings.tr(lang, 'Female', 'महिला')),
        (value: 'other', label: SurveyStrings.tr(lang, 'Other', 'अन्य')),
      ];

  static List<({String value, String label})> relationOptions(SurveyLang lang) =>
      [
        (value: 'head', label: SurveyStrings.tr(lang, 'Head', 'घरमूली')),
        (value: 'spouse', label: SurveyStrings.tr(lang, 'Spouse', 'पति/पत्नी')),
        (value: 'son', label: SurveyStrings.tr(lang, 'Son', 'छोरा')),
        (value: 'daughter', label: SurveyStrings.tr(lang, 'Daughter', 'छोरी')),
        (value: 'other', label: SurveyStrings.tr(lang, 'Other', 'अन्य')),
      ];

  static List<({String key, String label})> skillsList(SurveyLang lang) => [
        (key: 'farming', label: SurveyStrings.tr(lang, 'Farming', 'खेती')),
        (key: 'teaching', label: SurveyStrings.tr(lang, 'Teaching', 'शिक्षण')),
        (key: 'masonry', label: SurveyStrings.tr(lang, 'Masonry', 'डकर्मी')),
        (key: 'driving', label: SurveyStrings.tr(lang, 'Driving', 'चालक')),
        (key: 'other', label: SurveyStrings.tr(lang, 'Other', 'अन्य')),
      ];

  static List<({String value, String label})> cropOptions(SurveyLang lang) => [
        (value: 'rice', label: SurveyStrings.tr(lang, 'Rice', 'धान')),
        (value: 'maize', label: SurveyStrings.tr(lang, 'Maize', 'मकै')),
        (value: 'wheat', label: SurveyStrings.tr(lang, 'Wheat', 'गहुँ')),
        (value: 'millet', label: SurveyStrings.tr(lang, 'Millet', 'कोदो')),
        (value: 'vegetables', label: SurveyStrings.tr(lang, 'Vegetables', 'तरकारी')),
        (value: 'other', label: SurveyStrings.tr(lang, 'Other', 'अन्य')),
      ];
}

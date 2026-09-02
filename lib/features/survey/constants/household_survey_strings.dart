enum SurveyLang { en, ne }

class HouseholdSurveyStrings {
  const HouseholdSurveyStrings._();

  static String tr(SurveyLang lang, String en, String ne) =>
      lang == SurveyLang.ne ? ne : en;

  static List<String> stepTitles(SurveyLang lang) => [
        tr(lang, 'Basic Info', 'आधारभूत विवरण'),
        tr(lang, 'Household Head', 'घरमूली विवरण'),
        tr(lang, 'Household Members', 'घरपरिवार सदस्य'),
        tr(lang, 'Crops Grown', 'बाली विवरण'),
        tr(lang, 'Livelihood & Visits', 'जीविकोपार्जन र भ्रमण'),
        tr(lang, 'Documents', 'कागजातहरू'),
        tr(lang, 'Review', 'पुनरावलोकन'),
      ];

  static String requiredError(SurveyLang lang) =>
      tr(lang, 'This field is required', 'यो क्षेत्र आवश्यक छ');

  static String invalidError(SurveyLang lang) =>
      tr(lang, 'Please enter a valid value', 'मान्य मान प्रविष्ट गर्नुहोस्');

  static String yesLabel(SurveyLang lang) => tr(lang, 'Yes', 'हो');
  static String noLabel(SurveyLang lang) => tr(lang, 'No', 'होइन');
  static String selectPh(SurveyLang lang) =>
      tr(lang, 'Select…', 'चयन गर्नुहोस्…');

  static List<({String value, String label})> genderOptions(SurveyLang lang) =>
      [
        (value: 'male', label: tr(lang, 'Male', 'पुरुष')),
        (value: 'female', label: tr(lang, 'Female', 'महिला')),
        (value: 'other', label: tr(lang, 'Other', 'अन्य')),
      ];

  static List<({String value, String label})> relationOptions(
    SurveyLang lang,
  ) => [
        (value: 'head', label: tr(lang, 'Head', 'घरमूली')),
        (value: 'spouse', label: tr(lang, 'Spouse', 'पति/पत्नी')),
        (value: 'son', label: tr(lang, 'Son', 'छोरा')),
        (value: 'daughter', label: tr(lang, 'Daughter', 'छोरी')),
        (value: 'other', label: tr(lang, 'Other', 'अन्य')),
      ];

  static List<({String key, String label})> skillsList(SurveyLang lang) => [
        (key: 'farming', label: tr(lang, 'Farming', 'खेती')),
        (key: 'teaching', label: tr(lang, 'Teaching', 'शिक्षण')),
        (key: 'masonry', label: tr(lang, 'Masonry', 'डकर्मी')),
        (key: 'driving', label: tr(lang, 'Driving', 'चालक')),
        (key: 'other', label: tr(lang, 'Other', 'अन्य')),
      ];

  static List<({String value, String label})> cropOptions(SurveyLang lang) => [
        (value: 'rice', label: tr(lang, 'Rice', 'धान')),
        (value: 'maize', label: tr(lang, 'Maize', 'मकै')),
        (value: 'wheat', label: tr(lang, 'Wheat', 'गहुँ')),
        (value: 'millet', label: tr(lang, 'Millet', 'कोदो')),
        (value: 'vegetables', label: tr(lang, 'Vegetables', 'तरकारी')),
        (value: 'other', label: tr(lang, 'Other', 'अन्य')),
      ];
}

enum SurveyLang { en, ne }

class SurveyStrings {
  const SurveyStrings._();

  static String tr(SurveyLang lang, String en, String ne) =>
      lang == SurveyLang.ne ? ne : en;

  static String localeCode(SurveyLang lang) => lang == SurveyLang.ne ? 'ne' : 'en';
}

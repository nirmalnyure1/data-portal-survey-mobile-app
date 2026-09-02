import 'dart:convert';

class HouseholdMember {
  final int id;
  final String name;
  final String age;
  final String relation;
  final List<String> skills;

  const HouseholdMember({
    required this.id,
    this.name = '',
    this.age = '',
    this.relation = '',
    this.skills = const [],
  });

  HouseholdMember copyWith({
    int? id,
    String? name,
    String? age,
    String? relation,
    List<String>? skills,
  }) {
    return HouseholdMember(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      relation: relation ?? this.relation,
      skills: skills ?? this.skills,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'relation': relation,
        'skills': skills,
      };

  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      age: json['age'] as String? ?? '',
      relation: json['relation'] as String? ?? '',
      skills:
          (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
    );
  }
}

class HouseholdCrop {
  final String type;
  final int share;

  const HouseholdCrop({this.type = '', this.share = 0});

  HouseholdCrop copyWith({String? type, int? share}) {
    return HouseholdCrop(type: type ?? this.type, share: share ?? this.share);
  }

  Map<String, dynamic> toJson() => {'type': type, 'share': share};

  factory HouseholdCrop.fromJson(Map<String, dynamic> json) {
    return HouseholdCrop(
      type: json['type'] as String? ?? '',
      share: json['share'] as int? ?? 0,
    );
  }
}

class SurveyFileRef {
  final String name;
  final String? path;

  const SurveyFileRef({required this.name, this.path});

  Map<String, dynamic> toJson() => {'name': name, 'path': path};

  factory SurveyFileRef.fromJson(Map<String, dynamic> json) {
    return SurveyFileRef(
      name: json['name'] as String? ?? '',
      path: json['path'] as String?,
    );
  }
}

class HouseholdSurveyAnswers {
  final String headName;
  final String phone;
  final String email;
  final String wardNumber;
  final String address;
  final String toleLocation;
  final String dob;
  final String calendarType;
  final String gender;
  final String ownsLand;
  final String landArea;
  final int incomeRange;
  final int supportRating;
  final String lastVisitDateTime;
  final String preferredVisitTime;
  final String notesUrl;

  const HouseholdSurveyAnswers({
    this.headName = '',
    this.phone = '',
    this.email = '',
    this.wardNumber = '',
    this.address = '',
    this.toleLocation = '',
    this.dob = '',
    this.calendarType = 'ad',
    this.gender = '',
    this.ownsLand = '',
    this.landArea = '',
    this.incomeRange = 20000,
    this.supportRating = 0,
    this.lastVisitDateTime = '',
    this.preferredVisitTime = '',
    this.notesUrl = '',
  });

  HouseholdSurveyAnswers copyWith({
    String? headName,
    String? phone,
    String? email,
    String? wardNumber,
    String? address,
    String? toleLocation,
    String? dob,
    String? calendarType,
    String? gender,
    String? ownsLand,
    String? landArea,
    int? incomeRange,
    int? supportRating,
    String? lastVisitDateTime,
    String? preferredVisitTime,
    String? notesUrl,
  }) {
    return HouseholdSurveyAnswers(
      headName: headName ?? this.headName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      wardNumber: wardNumber ?? this.wardNumber,
      address: address ?? this.address,
      toleLocation: toleLocation ?? this.toleLocation,
      dob: dob ?? this.dob,
      calendarType: calendarType ?? this.calendarType,
      gender: gender ?? this.gender,
      ownsLand: ownsLand ?? this.ownsLand,
      landArea: landArea ?? this.landArea,
      incomeRange: incomeRange ?? this.incomeRange,
      supportRating: supportRating ?? this.supportRating,
      lastVisitDateTime: lastVisitDateTime ?? this.lastVisitDateTime,
      preferredVisitTime: preferredVisitTime ?? this.preferredVisitTime,
      notesUrl: notesUrl ?? this.notesUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'headName': headName,
        'phone': phone,
        'email': email,
        'wardNumber': wardNumber,
        'address': address,
        'toleLocation': toleLocation,
        'dob': dob,
        'calendarType': calendarType,
        'gender': gender,
        'ownsLand': ownsLand,
        'landArea': landArea,
        'incomeRange': incomeRange,
        'supportRating': supportRating,
        'lastVisitDateTime': lastVisitDateTime,
        'preferredVisitTime': preferredVisitTime,
        'notesUrl': notesUrl,
      };

  factory HouseholdSurveyAnswers.fromJson(Map<String, dynamic> json) {
    return HouseholdSurveyAnswers(
      headName: json['headName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      wardNumber: json['wardNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      toleLocation: json['toleLocation'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      calendarType: json['calendarType'] as String? ?? 'ad',
      gender: json['gender'] as String? ?? '',
      ownsLand: json['ownsLand'] as String? ?? '',
      landArea: json['landArea'] as String? ?? '',
      incomeRange: json['incomeRange'] as int? ?? 20000,
      supportRating: json['supportRating'] as int? ?? 0,
      lastVisitDateTime: json['lastVisitDateTime'] as String? ?? '',
      preferredVisitTime: json['preferredVisitTime'] as String? ?? '',
      notesUrl: json['notesUrl'] as String? ?? '',
    );
  }
}

class HouseholdSurveyDraft {
  final String lang;
  final int step;
  final bool submitted;
  final String? responseId;
  final HouseholdSurveyAnswers answers;
  final List<HouseholdMember> members;
  final int cropCount;
  final List<HouseholdCrop> crops;
  final SurveyFileRef? housePhoto;
  final SurveyFileRef? landCertificate;
  final Map<int, bool> stepTouched;
  final int? draftSavedAt;

  HouseholdSurveyDraft({
    this.lang = 'en',
    this.step = 0,
    this.submitted = false,
    this.responseId,
    this.answers = const HouseholdSurveyAnswers(),
    this.members = const [
      HouseholdMember(id: 1, name: '', age: '', relation: '', skills: []),
    ],
    this.cropCount = 0,
    this.crops = const [],
    this.housePhoto,
    this.landCertificate,
    this.stepTouched = const {},
    this.draftSavedAt,
  });

  static const int maxMembers = 12;
  static const int maxCrops = 6;
  static const int totalSteps = 7;

  HouseholdSurveyDraft copyWith({
    String? lang,
    int? step,
    bool? submitted,
    String? responseId,
    HouseholdSurveyAnswers? answers,
    List<HouseholdMember>? members,
    int? cropCount,
    List<HouseholdCrop>? crops,
    SurveyFileRef? housePhoto,
    SurveyFileRef? landCertificate,
    bool clearHousePhoto = false,
    bool clearLandCertificate = false,
    Map<int, bool>? stepTouched,
    int? draftSavedAt,
    bool clearDraftSavedAt = false,
    bool clearResponseId = false,
  }) {
    return HouseholdSurveyDraft(
      lang: lang ?? this.lang,
      step: step ?? this.step,
      submitted: submitted ?? this.submitted,
      responseId: clearResponseId ? null : responseId ?? this.responseId,
      answers: answers ?? this.answers,
      members: members ?? this.members,
      cropCount: cropCount ?? this.cropCount,
      crops: crops ?? this.crops,
      housePhoto: clearHousePhoto ? null : housePhoto ?? this.housePhoto,
      landCertificate:
          clearLandCertificate ? null : landCertificate ?? this.landCertificate,
      stepTouched: stepTouched ?? this.stepTouched,
      draftSavedAt:
          clearDraftSavedAt ? null : draftSavedAt ?? this.draftSavedAt,
    );
  }

  static HouseholdSurveyDraft empty() => HouseholdSurveyDraft();

  Map<String, dynamic> toJson() => {
        'lang': lang,
        'step': step,
        'submitted': submitted,
        'responseId': responseId,
        'answers': answers.toJson(),
        'members': members.map((m) => m.toJson()).toList(),
        'cropCount': cropCount,
        'crops': crops.map((c) => c.toJson()).toList(),
        'housePhoto': housePhoto?.toJson(),
        'landCertificate': landCertificate?.toJson(),
        'stepTouched': stepTouched,
        'draftSavedAt': draftSavedAt,
      };

  factory HouseholdSurveyDraft.fromJson(Map<String, dynamic> json) {
    final touchedRaw = json['stepTouched'];
    final stepTouched = <int, bool>{};
    if (touchedRaw is Map) {
      touchedRaw.forEach((k, v) {
        final key = int.tryParse(k.toString());
        if (key != null) stepTouched[key] = v == true;
      });
    }

    return HouseholdSurveyDraft(
      lang: json['lang'] as String? ?? 'en',
      step: json['step'] as int? ?? 0,
      submitted: json['submitted'] as bool? ?? false,
      responseId: json['responseId'] as String?,
      answers: HouseholdSurveyAnswers.fromJson(
        json['answers'] as Map<String, dynamic>? ?? {},
      ),
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => HouseholdMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [HouseholdMember(id: 1)],
      cropCount: json['cropCount'] as int? ?? 0,
      crops:
          (json['crops'] as List<dynamic>?)
              ?.map((e) => HouseholdCrop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      housePhoto: json['housePhoto'] != null
          ? SurveyFileRef.fromJson(json['housePhoto'] as Map<String, dynamic>)
          : null,
      landCertificate: json['landCertificate'] != null
          ? SurveyFileRef.fromJson(
              json['landCertificate'] as Map<String, dynamic>,
            )
          : null,
      stepTouched: stepTouched,
      draftSavedAt: json['draftSavedAt'] as int?,
    );
  }

  String encode() => jsonEncode(toJson());

  factory HouseholdSurveyDraft.decode(String raw) {
    return HouseholdSurveyDraft.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }
}

class HouseholdSurveySubmission {
  final String responseId;
  final int submittedAt;
  final HouseholdSurveyDraft draft;

  const HouseholdSurveySubmission({
    required this.responseId,
    required this.submittedAt,
    required this.draft,
  });

  Map<String, dynamic> toJson() => {
        'responseId': responseId,
        'submittedAt': submittedAt,
        'draft': draft.toJson(),
      };

  factory HouseholdSurveySubmission.fromJson(Map<String, dynamic> json) {
    return HouseholdSurveySubmission(
      responseId: json['responseId'] as String? ?? '',
      submittedAt: json['submittedAt'] as int? ?? 0,
      draft: HouseholdSurveyDraft.fromJson(
        json['draft'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

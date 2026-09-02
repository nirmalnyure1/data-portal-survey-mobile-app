/// Unwraps `{ data: ... }` envelopes from [ApiProvider] responses.
dynamic unwrapSurveyApiData(Map<String, dynamic> response) {
  var body = response['data'];
  if (body is Map && body.containsKey('data')) return body['data'];
  return body;
}

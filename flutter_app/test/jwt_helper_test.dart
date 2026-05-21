import 'package:bite_smart/core/utils/jwt_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JwtHelper Tests', () {
    const String testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
        'eyJpZCI6IjI0ZDZlMzJlLTIxOTYtNDI4ZC05N2Q3LTQ2YTk2NThmZjgzNSIsIm5hbWUiOiJKb2huIERvZSIsImlh'
        'dCI6MTc3OTM2NTczMiwiZXhwIjoxNzc5OTcwNTMyfQ.'
        '39MtV2HJ8R_s3WDzb_BTh2r3nfHYmTsS_ZZFYYthb-E';

    // The raw token from the user request payload section
    const String cleanedToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
        'eyJpZCI6IjI0ZDZlMzJlLTIxOTYtNDI4ZC05N2Q3LTQ2YTk2NThmZjgzNSIsIm5hbWUiOiJKb2huIERvZSIsImlhdCI6MTc3OTM2NTczMiwiZXhwIjoxNzc5OTcwNTMyfQ.'
        '39MtV2HJ8R_s3WDzb_BTh2r3nfHYmTsS_ZZFYYthb-E';

    test('decode should successfully decode JWT payload', () {
      final decoded = JwtHelper.decode(cleanedToken);
      expect(decoded, isNotNull);
      expect(decoded!['id'], '24d6e32e-2196-428d-97d7-46a9658ff835');
      expect(decoded['name'], 'John Doe');
      expect(decoded['iat'], 1779365732);
      expect(decoded['exp'], 1779970532);
    });

    test('getUserId should successfully extract user ID', () {
      final userId = JwtHelper.getUserId(cleanedToken);
      expect(userId, '24d6e32e-2196-428d-97d7-46a9658ff835');
    });

    test('getUserId should return fallback if token is invalid', () {
      final userId = JwtHelper.getUserId('invalid.token.here', fallback: 'fallback_id');
      expect(userId, 'fallback_id');
    });
  });
}

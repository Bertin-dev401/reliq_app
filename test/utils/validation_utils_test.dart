import 'package:flutter_test/flutter_test.dart';
import 'package:reliq_app/utils/validation_utils.dart';

void main() {
  group('Email Validation Tests', () {
    test('Valid emails pass validation', () {
      expect(ValidationUtils.validateEmail('user@example.com'), isNull);
      expect(ValidationUtils.validateEmail('test.email@domain.co.uk'), isNull);
      expect(ValidationUtils.validateEmail('user+tag@example.com'), isNull);
    });

    test('Invalid emails fail validation', () {
      expect(ValidationUtils.validateEmail(''), isNotNull);
      expect(ValidationUtils.validateEmail('invalid'), isNotNull);
      expect(ValidationUtils.validateEmail('user@'), isNotNull);
      expect(ValidationUtils.validateEmail('@example.com'), isNotNull);
    });
  });

  group('Password Validation Tests', () {
    test('Valid passwords pass validation', () {
      expect(ValidationUtils.validatePassword('ValidPass1'), isNull);
      expect(ValidationUtils.validatePassword('SecurePass123'), isNull);
      expect(ValidationUtils.validatePassword('MyPassword2024'), isNull);
    });

    test('Passwords without uppercase fail', () {
      final result = ValidationUtils.validatePassword('lowercase1');
      expect(result, isNotNull);
      expect(result, contains('uppercase'));
    });

    test('Passwords without lowercase fail', () {
      final result = ValidationUtils.validatePassword('UPPERCASE1');
      expect(result, isNotNull);
      expect(result, contains('lowercase'));
    });

    test('Passwords without numbers fail', () {
      final result = ValidationUtils.validatePassword('NoNumbers');
      expect(result, isNotNull);
      expect(result, contains('number'));
    });

    test('Passwords shorter than 8 characters fail', () {
      final result = ValidationUtils.validatePassword('Short1');
      expect(result, isNotNull);
      expect(result, contains('8 characters'));
    });
  });

  group('Name Validation Tests', () {
    test('Valid names pass validation', () {
      expect(ValidationUtils.validateName('John Doe'), isNull);
      expect(ValidationUtils.validateName('Mary Jane'), isNull);
      expect(ValidationUtils.validateName('AB'), isNull);
    });

    test('Empty name fails', () {
      expect(ValidationUtils.validateName(''), isNotNull);
      expect(ValidationUtils.validateName(null), isNotNull);
    });

    test('Name shorter than 2 characters fails', () {
      expect(ValidationUtils.validateName('A'), isNotNull);
    });

    test('Name longer than 100 characters fails', () {
      final longName = 'A' * 101;
      expect(ValidationUtils.validateName(longName), isNotNull);
    });
  });

  group('Denomination Validation Tests', () {
    test('Valid denominations pass', () {
      expect(ValidationUtils.validateDenomination('Catholic'), isNull);
      expect(ValidationUtils.validateDenomination('Protestant'), isNull);
      expect(ValidationUtils.validateDenomination('Orthodox'), isNull);
    });

    test('Invalid denominations fail', () {
      expect(ValidationUtils.validateDenomination(''), isNotNull);
      expect(ValidationUtils.validateDenomination(null), isNotNull);
      expect(ValidationUtils.validateDenomination('All'), isNotNull);
    });
  });

  group('Password Confirmation Validation Tests', () {
    test('Matching passwords pass', () {
      expect(
        ValidationUtils.validateConfirmPassword('ValidPass1', 'ValidPass1'),
        isNull,
      );
    });

    test('Non-matching passwords fail', () {
      final result = ValidationUtils.validateConfirmPassword(
        'ValidPass1',
        'DifferentPass1',
      );
      expect(result, isNotNull);
      expect(result, contains('do not match'));
    });

    test('Empty confirmation fails', () {
      expect(
        ValidationUtils.validateConfirmPassword('', 'ValidPass1'),
        isNotNull,
      );
    });
  });

  group('Required Field Validation Tests', () {
    test('Non-empty values pass', () {
      expect(ValidationUtils.validateRequired('value', 'Field'), isNull);
    });

    test('Empty values fail', () {
      expect(ValidationUtils.validateRequired('', 'Field'), isNotNull);
      expect(ValidationUtils.validateRequired(null, 'Field'), isNotNull);
      expect(ValidationUtils.validateRequired('   ', 'Field'), isNotNull);
    });
  });

  group('Phone Validation Tests', () {
    test('Valid Rwanda phone numbers pass', () {
      expect(ValidationUtils.validatePhone('0788123456'), isNull);
      expect(ValidationUtils.validatePhone('+250788123456'), isNull);
      expect(ValidationUtils.validatePhone('250788123456'), isNull);
    });

    test('Invalid phone numbers fail', () {
      expect(ValidationUtils.validatePhone(''), isNotNull);
      expect(ValidationUtils.validatePhone('123'), isNotNull);
      expect(ValidationUtils.validatePhone('+1234567890'), isNotNull);
    });
  });

  group('URL Validation Tests', () {
    test('Valid URLs pass', () {
      expect(ValidationUtils.validateUrl('https://example.com'), isNull);
      expect(ValidationUtils.validateUrl('http://www.example.com'), isNull);
      expect(ValidationUtils.validateUrl('example.com'), isNull);
    });

    test('Invalid URLs fail', () {
      expect(ValidationUtils.validateUrl(''), isNotNull);
      expect(ValidationUtils.validateUrl('not a url'), isNotNull);
    });
  });
}

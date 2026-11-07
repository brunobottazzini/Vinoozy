// InviteValidator (u7-sharing BR1.2, NFR4.9): one test per rule with its id,
// plus the boundary values of the email.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/sharing/domain/invite_validator.dart';
import 'package:vinoozy/sharing/domain/membership.dart';
import 'package:vinoozy/sharing/domain/sharing_error.dart';

import 'sharing_harness.dart';

SharingError? validate(
  String email, {
  List<Membership> members = const [],
  int memberSlots = 0,
}) => InviteValidator.validate(
  rawEmail: email,
  ownerEmail: owner.email,
  members: members,
  memberSlots: memberSlots,
);

/// An address of exactly [length] characters.
String emailOfLength(int length) {
  const domain = '@example.com';
  return '${'a' * (length - domain.length)}$domain';
}

void main() {
  group('normalizeEmail and isValidEmail (NFR4.9)', () {
    test('the key is trimmed and in lower case', () {
      expect(
        InviteValidator.normalizeEmail('  Giulia.Rossi@Example.COM '),
        'giulia.rossi@example.com',
      );
    });

    test('254 characters are accepted, 255 are not', () {
      expect(InviteValidator.isValidEmail(emailOfLength(254)), isTrue);
      expect(InviteValidator.isValidEmail(emailOfLength(255)), isFalse);
    });

    test('a slash, a space, a missing @ or a missing dot are rejected', () {
      expect(InviteValidator.isValidEmail('a/b@example.com'), isFalse);
      expect(InviteValidator.isValidEmail('a b@example.com'), isFalse);
      expect(InviteValidator.isValidEmail('example.com'), isFalse);
      expect(InviteValidator.isValidEmail('a@example'), isFalse);
      expect(InviteValidator.isValidEmail('a@@example.com'), isFalse);
      expect(InviteValidator.isValidEmail(''), isFalse);
    });

    test('Gmail dots are kept: the address must be written exactly', () {
      expect(
        InviteValidator.normalizeEmail('g.i.u@gmail.com'),
        'g.i.u@gmail.com',
      );
    });
  });

  group('validate', () {
    test('BR1.2 a valid new address passes', () {
      expect(validate('giulia@example.com'), isNull);
    });

    test('BR1.2 an invalid address is invalidEmail (AC8.1.3)', () {
      expect(validate('giulia'), SharingError.invalidEmail);
      expect(validate('   '), SharingError.invalidEmail);
      expect(validate(emailOfLength(255)), SharingError.invalidEmail);
      expect(validate('giu/lia@example.com'), SharingError.invalidEmail);
    });

    test('BR1.2 the owner address, in any case and with spaces, is '
        'selfInvite', () {
      expect(validate(' MARIO@example.com '), SharingError.selfInvite);
    });

    test('BR1.2 an invited or active address is alreadyInvited', () {
      final invited = membership(status: MemberStatus.invited);
      final active = membership(email: 'luca@example.com');
      expect(
        validate('Giulia@Example.com', members: [invited]),
        SharingError.alreadyInvited,
      );
      expect(
        validate('luca@example.com', members: [active]),
        SharingError.alreadyInvited,
      );
    });

    test('BR1.2 two open invitations are limitReached (AC8.1.2)', () {
      final members = [
        membership(),
        membership(email: 'luca@example.com', status: MemberStatus.invited),
      ];
      expect(
        validate('anna@example.com', members: members, memberSlots: 2),
        SharingError.limitReached,
      );
    });

    test('BR1.2 the counter alone also reaches the limit (stale list)', () {
      expect(
        validate('anna@example.com', memberSlots: 2),
        SharingError.limitReached,
      );
    });

    test('BR1.2 a revoked invitation can be renewed and does not count', () {
      final members = [
        membership(status: MemberStatus.revoked, closedBy: ClosedBy.owner),
        membership(email: 'luca@example.com'),
      ];
      expect(
        validate('giulia@example.com', members: members, memberSlots: 1),
        isNull,
      );
    });

    test('BR1.2 one open invitation leaves one place', () {
      expect(
        validate('anna@example.com', members: [membership()], memberSlots: 1),
        isNull,
      );
    });
  });

  group('usedPlaces (InviteForm x/2)', () {
    test('counts open invitations or the counter, whichever is larger', () {
      expect(InviteValidator.usedPlaces(const [], 0), 0);
      expect(InviteValidator.usedPlaces([membership()], 0), 1);
      expect(InviteValidator.usedPlaces(const [], 2), 2);
      expect(
        InviteValidator.usedPlaces([
          membership(status: MemberStatus.revoked),
        ], 0),
        0,
      );
    });

    test('never shows more than the limit', () {
      expect(InviteValidator.usedPlaces(const [], 5), 2);
    });
  });
}

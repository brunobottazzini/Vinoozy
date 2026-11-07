// Membership, AccessibleCellar and the enums of u7-sharing (C3, C4): the
// mapper never throws and falls back to values that grant nothing.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/sharing/domain/membership.dart';
import 'package:vinoozy/sharing/domain/sharing_error.dart';

import 'sharing_harness.dart';

void main() {
  group('Membership.fromMap', () {
    test('reads every C3 field and the additions of 2026-11-06', () {
      final at = DateTime.utc(2026, 11, 6);
      final member = Membership.fromMap('user-a', 'giulia@example.com', {
        MemberFields.inviteeEmail: 'giulia@example.com',
        MemberFields.inviteeUserId: 'user-b',
        MemberFields.permission: 'edit',
        MemberFields.status: 'active',
        MemberFields.invitedAt: at,
        MemberFields.ownerId: 'user-a',
        MemberFields.ownerName: 'Mario',
        MemberFields.inviteeName: 'Giulia',
        MemberFields.closedBy: 'owner',
        MemberFields.updatedAt: at,
        'unknown': true,
      });

      expect(member.cellarId, 'user-a');
      expect(member.memberKey, 'giulia@example.com');
      expect(member.inviteeUserId, 'user-b');
      expect(member.permission, MemberPermission.edit);
      expect(member.status, MemberStatus.active);
      expect(member.invitedAt, at);
      expect(member.updatedAt, at);
      expect(member.ownerName, 'Mario');
      expect(member.inviteeName, 'Giulia');
      expect(member.closedBy, ClosedBy.owner);
    });

    test('an empty map never throws and grants nothing', () {
      final member = Membership.fromMap('c', 'x@example.com', const {});

      expect(member.inviteeEmail, 'x@example.com');
      expect(member.status, MemberStatus.revoked);
      expect(member.permission, MemberPermission.read);
      expect(member.grantsAccess, isFalse);
      expect(member.isOpen, isFalse);
      expect(member.ownerId, '');
      expect(member.ownerLabel, '?');
      expect(member.closedBy, isNull);
    });

    test('wrong types and unknown values fall back safely', () {
      final member = Membership.fromMap('c', 'x@example.com', {
        MemberFields.status: 'owner',
        MemberFields.permission: 'admin',
        MemberFields.ownerName: 42,
        MemberFields.closedBy: true,
        MemberFields.invitedAt: '2026-11-06',
        MemberFields.inviteeUserId: 7,
      });

      expect(member.status, MemberStatus.revoked);
      expect(member.permission, MemberPermission.read);
      expect(member.ownerName, '');
      expect(member.closedBy, isNull);
      expect(member.invitedAt, isNull);
      expect(member.inviteeUserId, isNull);
    });
  });

  group('Membership helpers', () {
    test('BR1.4 only an active invitation grants access', () {
      expect(membership(status: MemberStatus.invited).grantsAccess, isFalse);
      expect(membership(status: MemberStatus.active).grantsAccess, isTrue);
      expect(membership(status: MemberStatus.revoked).grantsAccess, isFalse);
    });

    test('BR1.2 invited and active take a place, revoked does not', () {
      expect(membership(status: MemberStatus.invited).isOpen, isTrue);
      expect(membership(status: MemberStatus.active).isOpen, isTrue);
      expect(membership(status: MemberStatus.revoked).isOpen, isFalse);
    });

    test('BR1.12 the label is the name, or the email when it is missing', () {
      expect(membership().label, 'Giulia');
      expect(membership(inviteeName: null).label, 'giulia@example.com');
      expect(membership(inviteeName: '  ').label, 'giulia@example.com');
    });
  });

  group('AccessibleCellar (C4 listAccessibleCellars)', () {
    test('the personal cellar is the uid, owned, editable', () {
      final personal = AccessibleCellar.personal(
        uid: 'user-b',
        ownerName: 'Giulia',
      );
      expect(personal.cellarId, 'user-b');
      expect(personal.isPersonal, isTrue);
      expect(personal.canEdit, isTrue);
      expect(personal.isOwner, isTrue);
    });

    test('BR1.6 a shared cellar with read cannot edit, with edit can, and '
        'neither is the owner', () {
      final read = AccessibleCellar.shared(
        membership(permission: MemberPermission.read),
      );
      final edit = AccessibleCellar.shared(membership());

      expect(read.role, CellarRole.read);
      expect(read.canEdit, isFalse);
      expect(edit.role, CellarRole.edit);
      expect(edit.canEdit, isTrue);
      expect(read.isOwner || edit.isOwner, isFalse);
      expect(edit.ownerName, 'Mario');
      expect(edit.cellarId, 'user-a');
    });

    test('equality compares every field', () {
      final a = AccessibleCellar.shared(membership());
      final b = AccessibleCellar.shared(membership());
      final c = AccessibleCellar.shared(
        membership(permission: MemberPermission.read),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  test('every enum parses its stored names only', () {
    expect(MemberStatus.parse('invited'), MemberStatus.invited);
    expect(MemberStatus.parse(null), isNull);
    expect(MemberPermission.parse('read'), MemberPermission.read);
    expect(ClosedBy.parse('invitee'), ClosedBy.invitee);
    expect(ClosedBy.parse('Owner'), isNull);
  });

  test('SharingException names its error without personal data', () {
    expect(
      const SharingException(SharingError.limitReached).toString(),
      'SharingException(limitReached)',
    );
  });
}

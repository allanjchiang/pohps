import 'package:flutter_test/flutter_test.dart';
import 'package:pohps/data/patch_notes.dart';

void main() {
  final version = patchNotes.first.version;

  test('fresh install never shows notes', () {
    expect(
      patchNoteToShow(
        lastSeenVersion: null,
        currentVersion: version,
        hasCompletedOnboarding: false,
      ),
      isNull,
    );
  });

  test('existing user updating from an older version sees notes', () {
    expect(
      patchNoteToShow(
        lastSeenVersion: '1.1.8',
        currentVersion: version,
        hasCompletedOnboarding: true,
      )?.version,
      version,
    );
    // Updated from a release that predates version tracking.
    expect(
      patchNoteToShow(
        lastSeenVersion: null,
        currentVersion: version,
        hasCompletedOnboarding: true,
      )?.version,
      version,
    );
  });

  test('same version and versions without notes show nothing', () {
    expect(
      patchNoteToShow(
        lastSeenVersion: version,
        currentVersion: version,
        hasCompletedOnboarding: true,
      ),
      isNull,
    );
    expect(
      patchNoteToShow(
        lastSeenVersion: '1.1.8',
        currentVersion: '9.9.9',
        hasCompletedOnboarding: true,
      ),
      isNull,
    );
  });
}

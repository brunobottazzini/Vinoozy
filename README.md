# Vinoozy

App Android (Flutter) per gestire la propria cantina di vini, con salvataggio sul telefono anche offline e sincronizzazione su Firebase (Firestore) al ritorno della rete.

## Sviluppo

Requisiti: Flutter (versione in `.flutter-version`), Node.js (versione in `.nvmrc`), JDK 17 o superiore, un emulatore Android. Per sviluppare e testare non serve nessun account: si usano la Firebase Emulator Suite e il progetto demo `demo-vinoozy`.

```bash
flutter pub get
npm ci                                   # firebase-tools e test delle regole, versioni da package-lock.json

dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
dart run tool/gen_coverage_helper.dart && flutter test --coverage && tool/check_coverage.sh 80

# Regole Firestore, prova di riavvio, test end-to-end e prova con adb force-stop
# (emulatore Android avviato):
tool/verify_skeleton.sh
```

La configurazione di produzione (Firebase, Google Play, GitHub) è descritta in `docs/firebase-setup.md`; la checklist di ogni rilascio è in `docs/release-checklist.md`.

## Scelte tecniche che si discostano dal piano

| Scelta | Motivo |
|--------|--------|
| `minSdk` **24** (Android 7.0) invece di 23 | FlutterFire 7 (Firebase Android BoM 35) richiede almeno minSdk 24. Il design non fissava il minSdk. |
| `firebase-tools` **14.27.0**, bloccato in `package-lock.json` | La versione 15 rifiuta Java < 21, mentre lo sviluppo locale e la build Android usano JDK 17. In CI i job `rules` ed `e2e` usano comunque Java 21. Dependabot propone gli aggiornamenti; si passa alla 15 quando tutto l'ambiente usa Java 21. |
| `lib/l10n/app_pt.arb` con il solo `@@locale` | `flutter gen-l10n` non accetta `app_pt_BR.arb` senza un file base `pt`. I testi portoghesi stanno in `app_pt_BR.arb`; un telefono in portoghese europeo riceve l'inglese (BR5.1). Il file generato `app_localizations_pt.dart` resta in gran parte non coperto dai test, ma conta nella soglia dell'80% (nessuna esclusione). |

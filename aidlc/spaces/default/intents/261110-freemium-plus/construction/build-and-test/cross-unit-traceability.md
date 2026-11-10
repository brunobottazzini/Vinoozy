# Tracciabilità finale — Freemium e Plus

Fonte: `aidlc engine sensor-traceability --stage build-and-test` (lavoro senza Unit, scope `express`).

**Esito: PASS.** Tutti i 50 identificativi (FR1.1–FR9.3, NFR1–NFR7) sono coperti, e nessun elemento resta scoperto.

| ID | Coperto | Fase | File |
|---|---|---|---|
| FR1.1 | Sì | code-generation | `lib/plan/domain/entitlement.dart` |
| FR1.2 | Sì | code-generation | `lib/plan/capability_resolver.dart` |
| FR1.3 | Sì | code-generation | `lib/plan/ui/profile_plan_row.dart` |
| FR1.4 | Sì | code-generation | `lib/plan/data/entitlement_repository.dart` |
| FR1.5 | Sì | code-generation | `lib/plan/capability_resolver.dart` |
| FR2.1 | Sì | code-generation | `lib/cellar/data/active_wine_counter.dart` |
| FR2.2 | Sì | code-generation | `firestore.rules` |
| FR2.3 | Sì | code-generation | `tool/admin/migrate_capacity.mjs` |
| FR2.4 | Sì | code-generation | `lib/plan/capacity_guard.dart` |
| FR2.5 | Sì | code-generation | `lib/plan/ui/capacity_limit_sheet.dart` |
| FR2.6 | Sì | code-generation | `test/rules/compat/compat.rules.test.mjs` |
| FR3.1 | Sì | code-generation | `lib/plan/billing/billing_service.dart` |
| FR3.2 | Sì | code-generation | `lib/plan/ui/plus_screen.dart` |
| FR3.3 | Sì | code-generation | `functions/src/handlers/verify_purchase.ts` |
| FR3.4 | Sì | code-generation | `functions/src/handlers/play_rtdn.ts` |
| FR3.5 | Sì | code-generation | `lib/plan/ui/plus_screen.dart` |
| FR4.1 | Sì | code-generation | `tool/admin/grant_plus.mjs` |
| FR4.2 | Sì | code-generation | `tool/admin/grant_plus.mjs` |
| FR4.3 | Sì | code-generation | `integration_test/freemium_test.dart` |
| FR4.4 | Sì | code-generation | `tool/admin/lib/admin_context.mjs` |
| FR5.1 | Sì | code-generation | `lib/dev/dev_cheats.dart` |
| FR5.2 | Sì | code-generation | `lib/dev/dev_cheats.dart` |
| FR5.3 | Sì | code-generation | `lib/dev/ui/dev_tools_screen.dart` |
| FR5.4 | Sì | code-generation | `lib/plan/ui/profile_plan_row.dart` |
| FR5.5 | Sì | code-generation | `lib/dev/dev_cheats.dart` |
| FR5.6 | Sì | code-generation | `lib/dev/dev_entitlement_fixture.dart` |
| FR5.7 | Sì | code-generation | `tool/check_release_build.sh` |
| FR6.1 | Sì | code-generation | `lib/usage/cloud_usage_meter.dart` |
| FR6.2 | Sì | code-generation | `lib/usage/usage_cost.dart` |
| FR6.3 | Sì | code-generation | `functions/src/handlers/report_usage.ts` |
| FR6.4 | Sì | code-generation | `lib/usage/cloud_usage_meter.dart` |
| FR6.5 | Sì | code-generation | `functions/src/handlers/report_usage.ts` |
| FR7.1 | Sì | code-generation | `lib/ads/ads_gateway.dart` |
| FR7.2 | Sì | code-generation | `functions/src/handlers/ad_slots.ts` |
| FR7.3 | Sì | code-generation | `lib/ads/ui/dashboard_ad_slot.dart` |
| FR7.4 | Sì | code-generation | `lib/ads/dashboard_ad_controller.dart` |
| FR7.5 | Sì | code-generation | `lib/plan/ui/dashboard_plan_notices.dart` |
| FR7.6 | Sì | code-generation | `functions/src/handlers/ad_slots.ts` |
| FR8.1 | Sì | code-generation | `lib/l10n/app_it.arb` |
| FR8.2 | Sì | code-generation | `lib/plan/plan_notices.dart` |
| FR9.1 | Sì | code-generation | `docs/blaze-switch.md` |
| FR9.2 | Sì | code-generation | `functions/src/handlers/budget_alert.ts` |
| FR9.3 | Sì | code-generation | `firebase.json` |
| NFR1 | Sì | code-generation | `test/rules/freemium.rules.test.mjs` |
| NFR2 | Sì | code-generation | `test/rules/freemium.rules.test.mjs` |
| NFR3 | Sì | code-generation | `lib/usage/usage_uploader.dart` |
| NFR4 | Sì | code-generation | `lib/plan/data/policy_repository.dart` |
| NFR5 | Sì | code-generation | `.github/workflows/ci.yml` |
| NFR6 | Sì | code-generation | `functions/src/handlers/account_cleanup.ts` |
| NFR7 | Sì | code-generation | `lib/plan/plan_providers.dart` |

Elementi non coperti: nessuno.

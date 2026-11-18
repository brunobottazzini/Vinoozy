# Tracciabilità finale dei requisiti

Lavoro senza Unit (express). Fonte: `aidlc engine sensor-traceability --stage build-and-test`.

**Verdetto: FAIL** (3 requisiti non coperti in questa fase, tutti rinviati a Deployment Execution).

| ID | Coperto | Fase | File |
|---|---|---|---|
| FR1.1-FR1.3 | sì | code-generation | `tool/check_release_inputs.sh` |
| FR1.4 | sì | code-generation | `tool/check_release_inputs_test.sh` |
| FR1.5 | sì | code-generation | `.github/workflows/release.yml` |
| FR2.1-FR2.3 | sì | code-generation | `tool/play_api.sh` |
| FR2.4, FR3.1 | sì | code-generation | `tool/play_api_test.sh` |
| FR3.2 | sì | code-generation | `tool/check_release_inputs_test.sh` |
| FR3.3 | sì | code-generation | `tool/fixtures/release_inputs/service_account.json` |
| FR3.4 | sì | code-generation | `.github/workflows/ci.yml` |
| FR4.1-FR4.2 | sì | code-generation | `.github/workflows/promote.yml` |
| FR5.1-FR5.3 | sì | code-generation | `docs/github-actions-setup.md` |
| FR5.4 | sì | code-generation | `docs/firebase-setup.md` |
| FR6.1 | **no** | deployment-execution | release reale dopo i segreti e il push |
| FR6.2 | **no** | deployment-execution | push su `main` con il consenso del proprietario |
| FR7.1, FR7.3 | sì | code-generation | `test/sharing/active_cellar_build_test.dart` |
| FR7.2 | sì | code-generation | `lib/sharing/sharing_providers.dart` |
| FR7.4 | **no** | deployment-execution | E2E in GitHub Actions dopo il push |
| NFR1 | sì | code-generation | `tool/check_release_inputs_test.sh` |
| NFR2 | sì | code-generation | `.github/workflows/ci.yml` |
| NFR3 | sì | code-generation | `.github/workflows/release.yml` |
| NFR4 | sì | code-generation | `test/sharing/active_cellar_build_test.dart` |
| NFR5 | sì | code-generation | `tool/play_api_test.sh` |
| NFR6 | sì | code-generation | `docs/github-actions-setup.md` |

Elementi non coperti da portare all'approvazione: FR6.1, FR6.2, FR7.4.

# Automated validation

Create an isolated Python environment, install `tests/requirements.txt`, then run:

```text
python tests/validate.py
```

The validator parses every Lua file; rejects keyboard-enabled frames, keyboard event interception, binding XML, binding mutation, binding overrides and extra minimap texture/font layers; checks TOC/load/package shape; blocks access to RestedXP and Questie SavedVariables; verifies combat deferral and `OnShow` suppression; executes the real core Lua against a mocked Forever UI; toggles the feature repeatedly; checks final-state combat behavior; tests legacy minimap-position migration; and measures the packaged TGA's alpha, safety margin, circularity, centre and minimap-size contrast.

Result on 11 October 2026:

```text
PASS syntax_checks
PASS toc_and_package_checks
PASS boundary_checks
PASS artwork_checks
PASS minimap_geometry_checks
PASS legacy_cleanup_checks
PASS behavioral_checks
PASS documentation_checks
PASS all 8 validation groups
```

Automation does not replace the installed in-game test matrix. The owner completed the required full-client-restart isolation test and accepted the release on 11 October 2026. Future client, RestedXP, Questie or button-collector updates still require renewed observation of texture decoding, protected-frame behavior, integration visibility and icon presentation in the real client.

# Offline research and CI tools

`apk_inventory.py` uses Python 3.11+ standard library only. It requires an APK
obtained through a supported local file flow and an independently known SHA256.
It verifies that hash before reading members and checks member CRCs without
extracting or executing the APK. A 512 MiB total uncompressed-size resource limit
is unrelated to any application protocol limit.

It records ASCII-compatible UTF-8/UTF-16LE URI/path literals, source URI names and
JS bridge wrapper names with byte offsets relative to **uncompressed ZIP members**.
It does not recover method bodies, call graphs, authentication, request/response
schemas or runtime-generated endpoints. Path strings may be assets/filesystem
paths rather than HTTP endpoints. Complete runtime coverage is not claimed.

URLs omit userinfo, query values and fragments. Common identifier-shaped path
segments and private addresses are redacted conservatively. This is not a privacy
guarantee: review every output before sharing. Keep input APKs and unreviewed JSON
outside the repository; do not upload them as CI artifacts or commit them.

```sh
python3 tools/apk_inventory.py /absolute/private/input.apk \
  --expected-sha256 <independently-verified-sha256> \
  --output /absolute/private/inventory.json
PYTHONWARNINGS=error python3 -m unittest discover -s tools/tests -v
```

Only synthetic ZIP tests were run in this consumer environment; actual APK bytes
were unavailable. Existing source-attributed findings and module gaps are in
`docs/evidence/APP_INTEGRATION_CATALOG.md`.

`setup_flutter_ci.sh` is a GitHub-runner setup script pinned to an observed official
Flutter source revision. It is used by the prepared candidate workflow. Local
shell syntax checks do not prove SDK installation or CI execution. See
`docs/engineering/CI_VALIDATION.md` for actual status and blocked actions.

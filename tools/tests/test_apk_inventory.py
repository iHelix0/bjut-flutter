import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest
import zipfile


SPEC = importlib.util.spec_from_file_location(
    'apk_inventory', Path(__file__).resolve().parents[1] / 'apk_inventory.py'
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class InventoryTests(unittest.TestCase):
    def test_query_values_userinfo_and_fragments_are_not_retained(self):
        value = MODULE.safe_url(
            'https://fictional-user:fictional-secret@example.invalid/api/items'
            '?token=fictional-token&year=fictional-year#fictional-fragment'
        )
        self.assertEqual(value['host'], 'example.invalid')
        self.assertEqual(value['query_keys'], ['token', 'year'])
        self.assertTrue(value['had_userinfo'])
        for secret in ['fictional-user', 'fictional-secret', 'fictional-token',
                       'fictional-year', 'fictional-fragment']:
            self.assertNotIn(secret, str(value))
        self.assertIsNone(value['http_method'])
        self.assertIsNone(value['response_schema'])

    def test_private_addresses_and_identifier_shaped_paths_are_redacted(self):
        value = MODULE.safe_url('http://10.0.0.1/account/123456789/balance')
        self.assertEqual(value['host'], '<private-address>')
        self.assertEqual(value['path'], '/account/<redacted-segment>/balance')
        self.assertEqual(MODULE.safe_url('http://[::1]')['host'], '<private-address>')

    def test_utf8_and_utf16_offsets_point_to_member_bytes(self):
        for encoding, prefix in [('utf-8', b'\x00\x01'), ('utf-16le', b'\x01')]:
            url = 'https://example.invalid/api/list?week=fictional'
            raw = prefix + url.encode(encoding) + b'\x00\x00'
            record = next(row for row in MODULE.member_literals('synthetic.bin', raw)
                          if row['kind'] == 'url_literal')
            self.assertEqual(record['evidence']['member_byte_offset'], len(prefix))
            self.assertEqual(record['evidence']['encoding'], encoding)
            self.assertEqual(record['value']['path'], '/api/list')
            self.assertNotIn('fictional', str(record))

    def test_bridge_and_source_uris_do_not_claim_an_http_protocol(self):
        raw = (b"sendMessageToFlutter('fictionalHandler', null, callback);\x00"
               b'package:fictional/features/example.dart\x00')
        rows = MODULE.member_literals('synthetic.js', raw)
        bridge = next(row for row in rows if row['kind'] == 'js_bridge_literal')
        self.assertEqual(bridge['value']['handler'], 'fictionalHandler')
        self.assertTrue(any(row['kind'] == 'source_uri' for row in rows))
        self.assertTrue(all(row['confidence'] == 'literal_only_not_verified_interface'
                            for row in rows))

    def test_zip_scan_requires_hash_match_and_reads_all_members(self):
        with tempfile.TemporaryDirectory() as directory:
            apk = Path(directory) / 'synthetic.zip'
            with zipfile.ZipFile(apk, 'w', zipfile.ZIP_DEFLATED) as archive:
                archive.writestr('first.txt', 'https://example.invalid/api/one')
                archive.writestr('second.bin',
                                 'https://example.invalid/api/two'.encode('utf-16le'))
            digest = hashlib.sha256(apk.read_bytes()).hexdigest()
            with self.assertRaisesRegex(ValueError, 'SHA256 mismatch'):
                MODULE.inventory(apk, '0' * 64)
            result = MODULE.inventory(apk, digest)
            self.assertEqual(result['zip_member_count'], 2)
            members = {row['evidence']['member'] for row in result['records']}
            self.assertEqual(members, {'first.txt', 'second.bin'})
            self.assertTrue(result['publication_requires_review'])
            with self.assertRaisesRegex(ValueError, 'resource limit'):
                MODULE.inventory(apk, digest, max_uncompressed=1)

    def test_crc_corruption_is_rejected_even_when_outer_hash_matches(self):
        with tempfile.TemporaryDirectory() as directory:
            apk = Path(directory) / 'synthetic.zip'
            with zipfile.ZipFile(apk, 'w', zipfile.ZIP_STORED) as archive:
                archive.writestr('first.txt', 'https://example.invalid/api/one')
            raw = bytearray(apk.read_bytes())
            raw[raw.index(b'example.invalid')] = ord('X')
            apk.write_bytes(raw)
            digest = hashlib.sha256(raw).hexdigest()
            with self.assertRaises(zipfile.BadZipFile):
                MODULE.inventory(apk, digest)


if __name__ == '__main__':
    unittest.main()

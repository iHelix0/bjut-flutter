#!/usr/bin/env python3
"""Offline literal inventory, not an API/call-graph or runtime verifier.

Output requires human review before sharing. Never executes APK members or makes
network requests. Only ASCII-compatible URI literals in UTF-8/UTF-16LE are read;
encrypted, constructed, remote and non-ASCII URI forms may be missed.
"""

import argparse
import hashlib
import ipaddress
import json
from pathlib import Path
import re
from urllib.parse import parse_qsl, urlsplit
import zipfile


ASCII_RUN = re.compile(rb"[\x20-\x7e]{6,}")
UTF16_RUN = re.compile(rb"(?:[\x20-\x7e]\x00){6,}")
URL = re.compile(r"https?://[^\s\"'<>`\\]+")
PATH = re.compile(r"(?<![:/A-Za-z0-9])/(?:[A-Za-z0-9_.~-]+/)*[A-Za-z0-9_.~-]+")
SOURCE = re.compile(r"package:[A-Za-z0-9_./-]+\.dart")
BRIDGE = re.compile(
    r"\b(callHandler|sendMessageToFlutter)\s*\(\s*['\"]([A-Za-z_][A-Za-z0-9_.-]*)['\"]"
)
QUERY_KEY = re.compile(r"[A-Za-z_][A-Za-z0-9_.-]{0,63}\Z")


def safe_path(path):
    """Remove common identifier/token-shaped segments; not a privacy guarantee."""
    result = []
    for part in path.split('/'):
        if (
            re.fullmatch(r"[0-9]{5,}", part)
            or re.fullmatch(r"[0-9a-fA-F-]{16,}", part)
            or re.fullmatch(r"[A-Za-z0-9_=+%-]{32,}", part)
            or '@' in part
        ):
            part = '<redacted-segment>'
        result.append(part)
    return '/'.join(result)


def safe_url(literal):
    try:
        parsed = urlsplit(literal.rstrip(').,;]}'))
        host = parsed.hostname
        if not host:
            return None
        try:
            address = ipaddress.ip_address(host)
            if not address.is_global:
                host = '<private-address>'
        except ValueError:
            if '.' not in host or host.endswith(('.local', '.internal')):
                host = '<private-host>'
        # Do not retain userinfo, query values or fragments, even in evidence.
        return {
            'scheme': parsed.scheme,
            'host': host,
            'port': parsed.port,
            'path': safe_path(parsed.path),
            'query_keys': sorted({
                key if QUERY_KEY.fullmatch(key) else '<redacted-key>'
                for key, _ in parse_qsl(parsed.query, keep_blank_values=True)
            }),
            'had_userinfo': parsed.username is not None,
            'http_method': None,
            'request_schema': None,
            'response_schema': None,
            'authentication': 'unknown',
            'operation': 'unknown',
        }
    except ValueError:
        return None


def member_literals(member, raw):
    records = []
    for pattern, encoding, width in [
        (ASCII_RUN, 'utf-8', 1),
        (UTF16_RUN, 'utf-16le', 2),
    ]:
        for run in pattern.finditer(raw):
            text = run.group().decode(encoding)
            for kind, regex in [('url_literal', URL), ('path_literal', PATH),
                                ('source_uri', SOURCE), ('js_bridge_literal', BRIDGE)]:
                for match in regex.finditer(text):
                    location = {
                        'member': member,
                        'member_byte_offset': run.start() + match.start() * width,
                        'encoding': encoding,
                    }
                    if kind == 'url_literal':
                        value = safe_url(match.group())
                        if value is None:
                            continue
                    elif kind == 'js_bridge_literal':
                        value = {'wrapper': match.group(1), 'handler': match.group(2)}
                    elif kind == 'source_uri':
                        value = match.group()
                    else:
                        value = safe_path(match.group())
                    records.append({
                        'kind': kind,
                        'value': value,
                        'evidence': location,
                        'confidence': 'literal_only_not_verified_interface',
                    })
    return records


def inventory(apk, expected_sha256, max_uncompressed=512 * 1024 * 1024):
    apk = Path(apk)
    with apk.open('rb') as source:
        digest = hashlib.file_digest(source, 'sha256').hexdigest()
    if digest.lower() != expected_sha256.lower():
        raise ValueError('APK SHA256 mismatch; no members were scanned')
    records = []
    with zipfile.ZipFile(apk) as archive:
        members = archive.infolist()
        if sum(item.file_size for item in members) > max_uncompressed:
            raise ValueError('Archive exceeds offline scan resource limit')
        # Reading every member verifies its CRC. No extraction to filesystem.
        for member in members:
            if not member.is_dir():
                records.extend(member_literals(member.filename, archive.read(member)))
    return {
        'source_sha256': digest,
        'source_size_bytes': apk.stat().st_size,
        'zip_member_count': len(members),
        'scope': 'offline_ASCII_compatible_UTF8_UTF16LE_literals_all_ZIP_members',
        'publication_requires_review': True,
        'limits': [
            'No APK execution, network access, authentication or call-graph recovery.',
            'Paths include assets/filesystem/source false positives, not just HTTP.',
            'Method, schema and authentication are unknown unless separately evidenced.',
            'Runtime-built, encrypted, downloaded and non-ASCII URI forms may be absent.',
            'Redaction is conservative and incomplete; output must be reviewed.',
        ],
        'records': records,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('apk', type=Path)
    parser.add_argument('--expected-sha256', required=True)
    parser.add_argument('--output', type=Path, required=True,
                        help='Private JSON output; review before publishing')
    args = parser.parse_args()
    if not re.fullmatch(r'[0-9a-fA-F]{64}', args.expected_sha256):
        parser.error('--expected-sha256 must contain 64 hexadecimal characters')
    report = inventory(args.apk, args.expected_sha256)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print('Offline inventory written; review it before sharing. No network calls made.')


if __name__ == '__main__':
    main()

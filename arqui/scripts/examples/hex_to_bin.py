#!/usr/bin/env python3
"""Convert a .hex file with '//' comments into a raw binary file.

Usage:
    python arqui/scripts/hex_to_bin.py input.hex [-o output.bin]
"""
import argparse
import re
import sys
from pathlib import Path

def parse_hex_file(path):
    data = bytearray()
    with open(path, 'r', encoding='utf-8') as f:
        for lineno, line in enumerate(f, start=1):
            # Remove everything after '//' and strip
            line = line.split('//', 1)[0]
            if not line.strip():
                continue
            # Normalize separators and split into tokens
            line = line.replace(':', ' ').replace(',', ' ').replace('\t', ' ')
            tokens = line.split()
            for token in tokens:
                token = token.strip().strip(',;:')
                if not token:
                    continue
                if token.lower().startswith('0x'):
                    token = token[2:]
                # Keep only hex characters
                token = re.sub(r'[^0-9A-Fa-f]', '', token)
                if not token:
                    continue
                if len(token) % 2 != 0:
                    raise ValueError(f"Odd-length hex token at {path}:{lineno}: {token}")
                for i in range(0, len(token), 2):
                    data.append(int(token[i:i+2], 16))
    return data

def main():
    parser = argparse.ArgumentParser(description='Convert .hex with // comments to binary.')
    parser.add_argument('input', help='Input .hex file')
    parser.add_argument('-o', '--output', help='Output binary file (default: input.bin)')
    args = parser.parse_args()

    inp = Path(args.input)
    if not inp.exists():
        print(f"Input file not found: {inp}", file=sys.stderr)
        sys.exit(1)
    out = Path(args.output) if args.output else inp.with_suffix('.bin')

    try:
        data = parse_hex_file(inp)
    except Exception as e:
        print(f"Error processing {inp}: {e}", file=sys.stderr)
        sys.exit(2)

    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, 'wb') as fh:
        fh.write(data)
    print(f"Wrote {len(data)} bytes to {out}")

if __name__ == '__main__':
    main()

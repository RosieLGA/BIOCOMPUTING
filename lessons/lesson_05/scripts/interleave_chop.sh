#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <R1.fastq[.gz]> <R2.fastq[.gz]> <out.fastq[.gz]> <N_to_chop>" >&2
  exit 1
fi

R1="$1"
R2="$2"
OUT="$3"
N="$4"

# Validate N
if ! [[ "$N" =~ ^[0-9]+$ ]]; then
  echo "Error: N must be a nonnegative integer." >&2
  exit 1
fi

# Choose decoders for gz and plain text
if [[ "$R1" =~ \.gz$ ]]; then R1_STREAM=<(gzip -cd -- "$R1"); else R1_STREAM="$R1"; fi
if [[ "$R2" =~ \.gz$ ]]; then R2_STREAM=<(gzip -cd -- "$R2"); else R2_STREAM="$R2"; fi

# Writer: plain or gz
write_out() {
  if [[ "$OUT" =~ \.gz$ ]]; then
    gzip -c > "$OUT"
  else
    cat > "$OUT"
  fi
}

# Interleave while chopping N from seq and qual
awk -v n="$N" -v r2_path="$R2_STREAM" '
function chop(s) { return substr(s, n+1) }
BEGIN {
  # Open R2 once, read in lockstep with R1
  while ((getline h1 < ARGV[1]) > 0) {
    if ((getline s1 < ARGV[1]) <= 0 || (getline p1 < ARGV[1]) <= 0 || (getline q1 < ARGV[1]) <= 0) {
      print "Error: R1 appears truncated." > "/dev/stderr"; exit 2
    }

    if ((getline h2 < r2_path) <= 0 || (getline s2 < r2_path) <= 0 || (getline p2 < r2_path) <= 0 || (getline q2 < r2_path) <= 0) {
      print "Error: R2 has fewer records than R1." > "/dev/stderr"; exit 3
    }

    print h1
    print chop(s1)
    print p1
    print chop(q1)

    print h2
    print chop(s2)
    print p2
    print chop(q2)
  }
  # If R2 still has extra lines, that is a mismatch
  if ((getline extra < r2_path) > 0) {
    print "Error: R2 has more records than R1." > "/dev/stderr"; exit 4
  }
  close(r2_path)
}
' "$R1_STREAM" | write_out

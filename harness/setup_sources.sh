#!/usr/bin/env bash
# setup_sources.sh - fetch and pin every source tree the experiments use, under $HOME/thesis:
#   kyber-v0, kyber-v1        pq-crystals/kyber at the vulnerable and the fixed commit
#   mlkem-native-v2           mlkem-native v2.0.0, unmodified
#   mlkem-native-v3, -v2leak  v2.0.0 plus patches/v3_no_barriers.patch / v2leak_planted.patch
# Existing directories are left alone and only verified. dudect is vendored in third_party/.
set -u
ROOT="$HOME/thesis/thesis-artifact"; T="$HOME/thesis"
V0=b628ba78711bc28327dc7d2d5c074a00f061884e
V1=9b8d30698a3e7449aeb34e62339d4176f11e3c6c
V2=d1b2fe782888bdb761a50336012923180be7f502
fail() { echo "SETUP FAILED: $*"; exit 1; }

get() {  # get <dir> <url> <commit>
  if [ ! -d "$T/$1/.git" ]; then git clone -q "$2" "$T/$1" || fail "clone $1"; fi
  git -C "$T/$1" checkout -q "$3" 2>/dev/null || fail "checkout $3 in $1"
  [ "$(git -C "$T/$1" rev-parse HEAD)" = "$3" ] || fail "$1 is not at $3"
}
get kyber-v0 https://github.com/pq-crystals/kyber.git "$V0"
get kyber-v1 https://github.com/pq-crystals/kyber.git "$V1"
get mlkem-native-v2 https://github.com/pq-code-package/mlkem-native.git "$V2"
git -C "$T/mlkem-native-v2" diff --quiet || fail "mlkem-native-v2 has local changes"

patched() {  # patched <dir> <patch file>
  get "$1" "$T/mlkem-native-v2" "$V2"
  if git -C "$T/$1" diff --quiet; then git -C "$T/$1" apply "$ROOT/patches/$2" || fail "apply $2"; fi
  [ "$(git -C "$T/$1" diff | sha256sum | cut -d' ' -f1)" = "$(sha256sum < "$ROOT/patches/$2" | cut -d' ' -f1)" ] \
    || fail "$1 does not match patches/$2"
}
patched mlkem-native-v3 v3_no_barriers.patch
patched mlkem-native-v2leak v2leak_planted.patch

echo "sources ok:"
for d in kyber-v0 kyber-v1 mlkem-native-v2 mlkem-native-v3 mlkem-native-v2leak; do
  echo "  $d  $(git -C "$T/$d" rev-parse --short=12 HEAD)  $(git -C "$T/$d" diff --quiet && echo unmodified || echo patched)"
done

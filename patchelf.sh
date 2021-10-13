set -euo pipefail

declare -xp

$coreutils/bin/mkdir -p $out
echo "patchelf: patching ELF $1 with interpreter $2"
$patchelf/bin/patchelf --shrink-rpath --set-interpreter $2 \
    --output "$out/$3" $1 || {
    echo "patchelf: failed"
    exit 1
}
echo "patchelf: patched to $out/$3"

#!/bin/bash

# ------------------------------------------------------------------
# Script Name:   reconstructEvenOddStacks.sh
# Description:   Reconstruct aligned stacks from even and odd subdirectories.
# Author:        Virly Y. Ananda
# Dependencies:  IMOD (alignframes)
# ------------------------------------------------------------------

set -e

echo -e "\nUsage:\n
./reconstructEvenOddStacks.sh \\
  --alignedEvenStack path/to/aligned_EVEN/stack_binned4.st \\
  --alignedOddStack  path/to/aligned_ODD/stack_binned4.st \\
  --thickness <Estimate based on binning level> \\
  --gpu 1 \\
  --mdoc ./IMOD_meta/SampleA.mdoc\n
"

# ----------------------------
# Parse arguments
# ----------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --alignedEvenStack) EVEN_STACK="$2"; shift 2 ;;
    --alignedOddStack)  ODD_STACK="$2"; shift 2 ;;
    --thickness)        THICKNESS="$2"; shift 2 ;;
    --gpu)              GPU="$2"; shift 2 ;;
    --mdoc)             MDOC="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ----------------------------
# Validate inputs
# ----------------------------
[[ -z "$EVEN_STACK" || -z "$ODD_STACK" || -z "$THICKNESS" || -z "$MDOC" ]] && {
  echo "[ERROR] Missing required argument."; exit 1;
}
[[ ! -f "$MDOC" ]] && { echo "[ERROR] .mdoc file not found: $MDOC"; exit 1; }

# ----------------------------
# Extract tilt + rotation
# ----------------------------
TILT_FILE="tmp_angles.tlt"
awk '/TiltAngle/ {print $2}' "$MDOC" > "$TILT_FILE"
ROT=$(grep -m1 RotationAngle "$MDOC" | awk '{print $2}')
ROT=${ROT:-0}

# ----------------------------
# Generate base name from EVEN stack
# ----------------------------
BASE=$(basename "$EVEN_STACK" | sed -E 's/_?stack.*//')
BIN=$(echo "$EVEN_STACK" | grep -oE 'bin[0-9]+' | grep -oE '[0-9]+')
BIN=${BIN:-1}
ROT_TAG="rot${ROT}"

# ----------------------------
# Reconstruct EVEN
# ----------------------------
EVEN_OUT=$(dirname "$EVEN_STACK")/"${BASE}_bin${BIN}_${ROT_TAG}_even.mrc"
echo "[INFO] Reconstructing EVEN → $EVEN_OUT"
tilt -InputFile "$EVEN_STACK" \
     -OutputFile "$EVEN_OUT" \
     -TiltFile "$TILT_FILE" \
     -RotationAngle "$ROT" \
     -THICK "$THICKNESS" \
     -Mode 2 \
     -UseGPU "$GPU"

# ----------------------------
# Reconstruct ODD
# ----------------------------
ODD_OUT=$(dirname "$ODD_STACK")/"${BASE}_bin${BIN}_${ROT_TAG}_odd.mrc"
echo "[INFO] Reconstructing ODD → $ODD_OUT"
tilt -InputFile "$ODD_STACK" \
     -OutputFile "$ODD_OUT" \
     -TiltFile "$TILT_FILE" \
     -RotationAngle "$ROT" \
     -THICK "$THICKNESS" \
     -Mode 2 \
     -UseGPU "$GPU"

# ----------------------------
# Cleanup
# ----------------------------
rm -f "$TILT_FILE"

echo -e "\n[Reconstruction done!] Tomograms created:"
echo " $EVEN_OUT"
echo " $ODD_OUT"


#!/bin/bash

# ------------------------------------------------------------------
# Script Name:   generateEvenOddFrames.sh
# Description:   Aligns raw stack using alignframes (IMOD), applies gain (if any),
#                reads metadata (.mdoc), and splits aligned frames
#                into even and odd for Cryo-CARE input.
# Author:        Virly Y. Ananda
# Dependencies:  IMOD (alignframes)
# ------------------------------------------------------------------

set -e

echo -e "\nUsage:\n
./generateEvenOddFrames.sh --SampleDir ./OriginalSampleA --Binning 2 <OPTIONAL>
Parameters:\n
--SampleDir = Path to original tomogram parent directory (should contain the original unprocessed and processed data/metadata)\n
Example of original parent directory:\n
/OriginalSampleA/
├── TiltSeries/
│   ├── SampleA_000.tiff
│   ├── SampleA_001.tiff
│   └── SampleA_002.tiff
│   └── …
│   └── SampleA_100.tiff
│   └── SampleA_stack.mrc (Compilation of raw frames)
├── GainRef/
│   ├── Gain_Reference.dm4
├── IMOD(metadata)/
│   ├── SampleA.mdoc
│   ├── SampleA.tlt
│   ├── SampleA.xtlt
│   ├── eraser.com
│   └── …
├── Aligned/
│   ├── SampleA_unbinned_st.mrc (stacks)
│   ├── SampleA_bin4_st.mrc (stacks)
├── Reconstruction/
│   ├── SampleA_unbinned_tomo.mrc (tomogram)
│   ├── SampleA_bin4_tomo.mrc (tomogram)
"

# ----------------------------
# Parse Arguments
# ----------------------------
SAMPLE_DIR=""
BINING=$1 # Default is unbinned. User can choose if binned. Usually binned.

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --SampleDir)
      SAMPLE_DIR="$2"
      shift 2
      ;;
    --Binning)
      BINNING="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$SAMPLE_DIR" ]]; then
  echo "[ERROR] Missing required argument: Provide sample directory!"
  exit 1
fi

# ----------------------------
# Define Paths
# ----------------------------
TILTSTACK="$SAMPLE_DIR/TiltSeries/SampleA_stack.mrc"
MDOC_FILE=$(find "$SAMPLE_DIR/IMOD" -type f -name "*.mdoc" | head -n 1)
GAIN_REF=$(find "$SAMPLE_DIR/GainRef" -type f -name "*.dm4" | head -n 1)
CRYOCARE_DIR="$SAMPLE_DIR/CryoCARE"

mkdir -p "$CRYOCARE_DIR"
cd "$CRYOCARE_DIR"

ALIGNED_OUTPUT="aligned_stack.mrc"
ALIGN_LOG="alignedframes.log"
DEBUG_OUTPUT_DIR="aligned_debugOutput"
EVEN_DIR="aligned_EVEN"
ODD_DIR="aligned_ODD"

mkdir -p "$DEBUG_OUTPUT_DIR" "$EVEN_DIR" "$ODD_DIR"

# ----------------------------
# Run alignframes with metadata
# ----------------------------
echo "[INFO] Running alignframes on: $TILTSTACK"
echo "[INFO] Binning level: $BINNING"


if [[ ! -f "$TILTSTACK" ]]; then
  echo "[ERROR] Tilt stack not found: $TILTSTACK"
  exit 1
fi

if [[ -f "$MDOC_FILE" ]]; then
  echo "[INFO] Using metadata: $MDOC_FILE"
  if [[ -f "$GAIN_REF" ]]; then
    echo "[INFO] Using gain reference: $GAIN_REF"
    alignframes -mdoc "$MDOC_FILE" -gain "$GAIN_REF" \
      -output "$ALIGNED_OUTPUT" -log "$ALIGN_LOG" \
      -adjust -binning "$BINNING" -DebugOutput 1000
  else
    echo "[WARNING] Gain reference not found. Proceeding without gain."
    alignframes -mdoc "$MDOC_FILE" \
      -output "$ALIGNED_OUTPUT" -log "$ALIGN_LOG" \
      -adjust -binning "$BINNING" -DebugOutput 1000
  fi
else
  echo "[ERROR] No .mdoc metadata found in $SAMPLE_DIR/IMOD"
  exit 1
fi

# ----------------------------
# Move faimg*.mrc to debug folder
# ----------------------------
if ls faimg-*.mrc 1> /dev/null 2>&1; then
  mv faimg-*.mrc "$DEBUG_OUTPUT_DIR/"
else
  echo "[ERROR] No faimg-*.mrc files were generated. Exiting..."
  exit 1
fi

# ----------------------------
# Split aligned frames: Even vs Odd
# ----------------------------
echo "[INFO] Splitting aligned frames into even/odd directories..."

for file in "$DEBUG_OUTPUT_DIR"/faimg-*.mrc; do
  filename=$(basename "$file")
  frame_num=$(echo "$filename" | grep -oE '[0-9]+' | tail -1)

  if (( frame_num % 2 == 0 )); then
    cp "$file" "$EVEN_DIR/$filename"
    echo " EVEN $filename"
  else
    cp "$file" "$ODD_DIR/$filename"
    echo " ODD  $filename"
  fi
done

# ----------------------------
# Summary
# ----------------------------
echo -e "\n[DONE] Alignment and splitting completed for sample: $SAMPLE_DIR"
echo " Aligned stack:         $CRYOCARE_DIR/$ALIGNED_OUTPUT"
echo " Even aligned frames:   $CRYOCARE_DIR/$EVEN_DIR"
echo " Odd aligned frames:    $CRYOCARE_DIR/$ODD_DIR"
echo " Debug output frames:   $CRYOCARE_DIR/$DEBUG_OUTPUT_DIR"


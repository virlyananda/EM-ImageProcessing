#!/bin/bash

Help()
{
   # Display Help
   echo "This script is created to generate even and odd stacks for cryo-ET processing."
   echo "Author: Virly Y. Ananda (IMOD embedded)"
   echo "Affiliation: Department of Molecular Biology, Massachusetts General Hospital"
   echo "Date: 06/13/23"
   echo
   echo "Syntax: bash GenerateStacks.sh [-m|s|b|g|h|S|p|I|M]"
   echo "options:"
   echo "m     Provide MDOC file name."
   echo "s     Provide output stack name."
   echo "b     Provide binning size."
   echo "g     Provide path to gain reference."
   echo "o     Provide name for output directory."
   echo "S     Stack size in X and Y (X,Y)."
   echo "p     Output pixel size in Angstrom (X,Y,Z)."
   echo "I     IMOD location."
   echo "M     IMOD files stack name."
   echo
}

# Get the options
while getopts ":h:m:s:b:g:o:S:p:I:M:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      m) # Enter a name
         MDOC_FILE=$OPTARG;;
      s) # Age
         OUTPUT_FILE=$OPTARG;;
      b) # Binning size
	 BINNING=$OPTARG;;
      g) # Gain reference
         GAIN_REF=$OPTARG;;
      o) # Output directory
         OUTPUT_DIR=$OPTARG;;
      S)# Stack size
	 output_size=$OPTARG;;
      p)# Pixel size
         pixel_size=$OPTARG;;
      I)# IMOD Location
	 IMOD_LOC=$OPTARG;;
      M)# IMOD Original Stack name
	 IMOD_STACK=$OPTARG;;
      *) # Invalid option
	 Help
         exit;;
   esac
done


echo "MDOC File = $MDOC_FILE"
echo "Stack output = $OUTPUT_FILE"
echo "Binning = $BINNING"
echo "Gain Ref. = $GAIN_REF"
echo "Creating new output directory..."
mkdir -p $PWD/$OUTPUT_DIR

echo "Generating full stack and splitting fractions ..."
alignframes -mdoc $MDOC_FILE -output ./$OUTPUT_DIR/$OUTPUT_FILE -adjust -binning $BINNING -gain $GAIN_REF -DebugOutput 10000

# Renaming and sorting even and odd fractions:

for file in *faimg-[0-9].mrc;
  do
  mv "$file" "${file/faimg-/faimg-0}"
done

# Creating odd and even subdirectories:

if [ -d "$PWD/odd" ] && [ -d "$PWD/even"];
then
    echo "Directories exist." 
else
    echo "Creating odd and even directories ..."
    mkdir -p odd
    mkdir -p even
fi

# Moving even and odd fractions to their respective directory:

echo "Moving even fractions to assigned directory ..."
mv *[02468].mrc ./even/

echo "Done!"

echo "Moving odd fractions to assigned directory ..."
mv *[13579].mrc ./odd/

echo "Done!"

### Please check if the files are sorted ###

# Generating full even stack while adjusting pixel size

echo "Generating even stack ..."

newstack -ModeToOutput 0 -SizeToOutputInXandY $output_size $PWD/even/*.mrc $PWD/even/stack_MC.mrc

echo "Even stack generated!"

echo "Generating odd stack ..."
newstack -ModeToOutput 0 -SizeToOutputInXandY $output_size $PWD/odd/*.mrc $PWD/odd/stack_MC.mrc

echo "Odd stack generated!"

echo "Adjusting pixel size on even stack ..."
alterheader $PWD/even/stack_MC.mrc -PixelSize $pixel_size

echo "Even stack pixel size adjusted!"

echo "Adjusting pixel size on odd stack ..."
alterheader $PWD/odd/stack_MC.mrc -PixelSize $pixel_size

echo "Odd stack pixel size adjusted!"

echo "Even and odd stacks successfully generated!"

echo "Please revise supporting files: eraser.com, newst.com and tilt.com"

# Copying .com files and their supporting data

echo "Copying supporting files from IMOD ..."

echo "Copying eraser.com file ..."
cp $IMOD_LOC/eraser.com $PWD/even/
cp $IMOD_LOC/eraser.com $PWD/odd/

echo "Copying newst.com file ..."
cp $IMOD_LOC/newst.com $PWD/even/
cp $IMOD_LOC/newst.com $PWD/odd/

echo "Copying tilt.com file ..."
cp $IMOD_LOC/tilt.com $PWD/even/
cp $IMOD_LOC/tilt.com $PWD/odd/

echo "Copying supporting files ..."
cp $IMOD_LOC/$IMOD_STACK.xf $PWD/even/
cp $IMOD_LOC/$IMOD_STACK.xtilt $PWD/even/
cp $IMOD_LOC/$IMOD_STACK.tlt $PWD/even/

cp $IMOD_LOC/$IMOD_STACK.xf $PWD/odd/
cp $IMOD_LOC/$IMOD_STACK.xtilt $PWD/odd/
cp $IMOD_LOC/$IMOD_STACK.tlt $PWD/odd/

## PLEASE CHECK THE CONTENT OF YOUR .XF, .XTILT, AND .TLT FILES BEFORE GENERATING TOMOGRAM ##

#!/bin/bash

# Relocating working directory containing supporting files:

echo "Your working directory containing raw fractions (with cd): "
read WORK_DIR

source $WORK_DIR

echo "Provide .mdoc file: "
read MDOC_FILE

echo "Provide output file: "
read OUTPUT_FILE

echo "Provide binning size (2 int): "
read BINNING

echo "Provide gain reference: "
read GAIN_REF

echo "Output directory: "
read OUTPUT_DIR

echo "Creating output directory ..."
mkdir $OUTPUT_DIR

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

# Sorting filenames
#echo "Sorting filenames in even ..."
#ls -v1 ./even/*.mrc >> ./even/sorted

echo "Done!"

echo "Moving odd fractions to assigned directory ..."
mv *[13579].mrc ./odd/

# Sorting filenames
#echo "Sorting filenames in odd ..."
#ls -v1 ./odd/*.mrc >> ./odd/sorted

echo "Done!"

# Generating full even stack while adjusting pixel size

echo "Output stack size in X and Y (X,Y): "
read output_size

echo "Output pixel size in Angstrom (X,Y,Z): "
read pixel_size

echo "Generating even stack ..."

newstack -ModeToOutput 0 -SizeToOutputInXandY $output_size ./even/*.mrc ./even/stack_MC.mrc

#cat ./even/sorted | while read line; do newstack -ModeToOutput 0 -SizeToOutputInXandY $output_size $line ./even/stack_MC.mrc; done


echo "Even stack generated!"

echo "Generating odd stack ..."
newstack -ModeToOutput 0 -SizeToOutputInXandY $output_size ./odd/*.mrc ./odd/stack_MC.mrc

#cat ./odd/sorted | while read line; do newstack -ModeToOutput 0 -SizeToOutputInXandY $output_size $line ./odd/stack_MC.mrc; done

echo "Odd stack generated!"

echo "Adjusting pixel size on even stack ..."
alterheader ./even/stack_MC.mrc -PixelSize $pixel_size

echo "Even stack pixel size adjusted!"

echo "Adjusting pixel size on odd stack ..."
alterheader ./odd/stack_MC.mrc -PixelSize $pixel_size

echo "Odd stack pixel size adjusted!"

echo "Even and odd stacks successfully generated!"

# Excluding views in full stack

while true; do
read -p "Would you like to exclude other views in even/odd stack? (Yes/No) " yn

case $yn in
    Yes ) echo Proceeding to exclude other views;
           break;;
    No ) echo Exiting ...;
        exit;;
    *) echo Invalid response;
       exit 1;;
esac

done

echo "Which views would you like to exclude? "
read exview

echo "Excluding views $exview from even stack ..."

excludeviews ./even/stack_MC.mrc -v $exview

echo "Excluding views from odd stack ..."
excludeviews ./odd/stack_MC.mrc -v $exview

echo "Please review your current stack properties: "

echo "Even stack updated: "
header ./even/stack_MC.mrc

echo "Odd stack updated: "
header ./odd/stack_MC.mrc

# Continue whether to exclude views in stack
while true; do
read -p "Would you like to exclude other views in even/odd stack? (Yes/No) " yn

case $yn in
    Yes ) echo Proceeding to exclude other views;
           break;;
    No ) echo Exiting ...;
        exit;;
    *) echo Invalid response;
       exit 1;;
esac

done

echo "Which views would you like to exclude? (Views range only) "
read exview

echo "Excluding views from even stack ..."
excludeviews ./even/stack_MC.mrc -v $exview

echo "Excluding views from odd stack ..."
excludeviews ./odd/stack_MC.mrc -v $exview

echo "Please review your current stack properties: "

echo "Updated even stack: "
header ./even/stack_MC.mrc

echo "Updated odd stack: "
header ./odd/stack_MC.mrc

# Copying .com files and their supporting data

echo Copying supporting files from IMOD ...

echo "Provide your IMOD files location: "
read IMOD_LOC

echo "Provide your stack name from IMOD (no extension): "
read IMOD_STACK

echo "Copying eraser.com file ..."
cp $IMOD_LOC/eraser.com ./even/
cp $IMOD_LOC/eraser.com ./odd/

echo "Copying newst.com file ..."
cp $IMOD_LOC/newst.com ./even/
cp $IMOD_LOC/newst.com ./odd/

echo "Copying tilt.com file ..."
cp $IMOD_LOC/tilt.com ./even/
cp $IMOD_LOC/tilt.com ./odd/

echo "Copying supporting files ..."
cp $IMOD_LOC/$IMOD_STACK.xf ./even/
cp $IMOD_LOC/$IMOD_STACK.xtilt ./even/
cp $IMOD_LOC/$IMOD_STACK.tlt ./even/

cp $IMOD_LOC/$IMOD_STACK.xf ./odd/
cp $IMOD_LOC/$IMOD_STACK.xtilt ./odd/
cp $IMOD_LOC/$IMOD_STACK.tlt ./odd/

echo "Supporitng files successfully copied! Please check the parameters before aligning even/odd stacks!"

cat ./even/eraser.com
cat ./even/newst.com
cat ./even/tilt.com

echo "Please check the parameters of each file before proceeding!"

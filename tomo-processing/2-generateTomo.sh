#!/bin/bash

# Relocating working directory

echo "Your working directory: "
read WORK_DIR

source $WORK_DIR/even/

# Run eraser.com: Even

echo "Running eraser.com: Erasing X-rays from even images ..."
submfg eraser.com

# Run newst.com: Even

echo "Running newst.com: Aligning even stacks ..."
submfg newst.com

# Run tilt.com: Even

echo "Running tilt.com: Generating even tomogram ..."
submfg tilt.com

# Rotate Even Tomogram
while true; do
read -p "Would you like to rotate even tomogram? (Yes/No) " yn

case $yn in
    Yes ) echo Proceeding to rotate even tomogram ...;
           break;;
    No ) echo Exiting ...;
        exit;;
    *) echo Invalid response;
       exit 1;;
esac

done

echo "Provide the name of current even tomogram (with extension): "
read currentEvenTomo

echo "Provide the name of the final even tomogram (with extension): "
read rotEvenTomo

echo "Rotating even tomogram ..."
trimvol -rx ./$currentEvenTomo ./$rotEvenTomo

echo "Successfully rotated even tomogram."

# Relocating to odd
source $WORK_DIR/odd/

# Run eraser.com

echo "Running eraser.com: Erasing X-rays from odd images ..."
submfg eraser.com

# Run newst.com

echo "Running newst.com: Aligning odd stacks ..."
submfg newst.com

# Run tilt.com

echo "Running tilt.com: Generating odd tomogram ..."
submfg tilt.com

# Rotate odd tomogram (Optional)
while true; do
read -p "Would you like to rotate odd tomogram? (Yes/No) " yn

case $yn in
    Yes ) echo Proceeding to rotate odd tomogram ...;
           break;;
    No ) echo Exiting ...;
        exit;;
    *) echo Invalid response;
       exit 1;;
esac

done

echo "Provide the name of current odd tomogram (with extension): "
read currentOddTomo

echo "Provide the name of the final odd tomogram (with extension): "
read rotOddTomo

echo "Rotating odd tomogram ..."
trimvol -rx ./$currentOddTomo ./$rotOddTomo

echo "Successfully rotated odd tomogram!"

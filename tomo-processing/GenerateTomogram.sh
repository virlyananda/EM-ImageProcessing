#!/bin/bash

Help()
{
   # Display Help
   echo
   echo "This script is created to construct even and odd tomogram for cryo-ET processing."
   echo "Please check the inputs in the supporting files before running this script."
   echo "Author: Virly Y. Ananda (IMOD embedded)"
   echo "Affiliation: Department of Molecular Biology, Massachusetts General Hospital"
   echo "Date: 06/13/23"
   echo
   echo "Syntax: bash GenerateTomogram.sh [-e|o|E|O|h]"
   echo "options:"
   echo "e     Provide name of even tomogram."
   echo "o     Provide name of odd tomogram."
   echo "E     Provide name for rotated even tomogram."
   echo "O     Provide name for rotated odd tomogram."
   echo "h     Print Help."
   echo
}

# Provide options
while getopts ":h:e:o:E:O:" option; do
   case $option in
      h) # Display help
	 Help
	 exit;;
      e) # Enter even tomogram name
         e_TOMO=$OPTARG;;
      o) # Enter odd tomogram name
	 o_TOMO=$OPTARG;;
      E) # Enter rotated even tomogram name
	 E_TOMO=$OPTARG;;
      O) # Enter rotated odd tomogram name
	 O_TOMO=$OPTARG;;
      *) # Invalid option
	 Help
	 exit;;
   esac
done

echo "Unrotated even tomogram Name: $e_TOMO"
echo "Unrotated odd tomogram Name: $o_TOMO"
echo "Rotated even tomogram Name: $E_TOMO"
echo "Rotated odd tomogram Name: $O_TOMO"

echo "Runing eraser.com: Erasing X-rays from even and odd stacks..."
submfg $PWD/even/eraser.com
submfg $PWD/odd/eraser.com

echo "Running newst.com: Aligning even and odd stacks..."
submfg $PWD/even/newst.com
submfg $PWD/odd/newst.com

echo "Running tilt.com: Generating 3D reconstruction (tomogram) on even and odd stacks..."
submfg $PWD/even/tilt.com
submfg $PWD/odd/tilt.com

echo "Rotating even and odd tomograms..."
trimvol -rx $PWD/$e_TOMO $PWD/$E_TOMO
trimvol -rx $PWD/$o_TOMO $PWD/$O_TOMO

echo "Successfully rotated both tomograms. Please input the 2 tomograms onto cryoCARE!"

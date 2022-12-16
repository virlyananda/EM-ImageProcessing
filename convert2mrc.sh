#!/bin/bash

# This script is used to batch convert multiple .tiff files to .mrc stacks.
# As a result, this will generate 1 stack .mrc file for every .tiff files.

# For each file ending in .tiff, using tif2mrc and convert to .mrc stacks.
# -p refers to  number of pixels in angstroms(A).

# To run this, simply put this script in directory that contains .tiff files,
# and on terminal run $chmod u+x , then $ ./convert2mrc.sh

for file in *.tiff; do
  tif2mrc -p 2.255 ./"$file" ./"${file%.tiff}.mrc"
done

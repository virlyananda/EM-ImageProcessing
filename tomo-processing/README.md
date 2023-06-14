## **Generating Even and Odd Tomograms** ##

Author: Virly Y. Ananda <br>
Affiliation: Department of Molecular Biology, Massachusetts General Hospital <br>
Date: 06/13/2023

**Main Steps on Generating a Tomogram**:
* **2D Stacks Alignment**: This is where a list of .TIFF formatted fractions are generated into 2D stacks which then can be aligned accordingly. Certain views can be excluded in this phase.
* **3D Reconstruction**: This is where tomogram is generated from the aligned 2D stacks.
<br>

Aligning 2D stacks after fractions(frames) acquisitions can be processed differently on whether the data needs further adjustments (e.g., *image size*, *pixel size*, *excluded views*, etc.) before proceeding to 3D reconstructions.

We implemented 2D stacks alignment with **IMOD** and split our fractions with ***alignframes*** which we embedded onto our bash scripts.

### **Align Even and Odd 2D Stacks** ###

<img width="710" alt="Screenshot 2023-06-13 at 2 07 14 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/484ce348-8cdf-4ff3-ae42-2fd809e1d719">

<br>

#### **Walkthrough** #### 

**Step 1**: Go to the directory where your IMOD file and .TIFF fractions are stored. <br>
**Step 2**: Run the script on terminal, simply run like the example shown below: <br>

**bash GenerateStacks.sh** **-m** [mdocfile].mdoc **-s** [stackname].mrc **-b** 8,2 **-g** [gainreffile].dm4 **-o** [output_directory] **-S** [sizeY,sizeX] **-p** [A,A,A] **-I** [pathwaytoIMODfile] **-M** [imodfilenames]

Please refer to **alignframes** website to check further information on the parameters.

### **Construct Even and Odd Tomograms** ###

<img width="735" alt="Screenshot 2023-06-13 at 3 14 48 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/219425fc-ce97-44a7-826c-766dce9c1804">

#### **Walkthrough** #### 

**Step 1**: Confirm you have the original metafile copied to both even and odd directories.
  * Metafiles: .xf, .xtilt, .tlt (these files contain necessary rotations information)
  * Parameter files: The .com files such as eraser.com, newst.com and tilt.com (these files contain necessary parameters to align and generate tomogram). <br>
**Step 2**: Update necessary information within the .com files. Normally, adjustment in stack output names, tomogram names, GPU usage, mode, and stack sizes must be checked. Mode should be 2 (floating-type). <br>
**Step 3**: Check whether your tomogram should be rotated. If so, you may continue. <br>
**Step 4**: Run the script to generate even and odd tomograms. <br>
**Step 5**: Feed even and odd tomograms to cryoCARE scripts. Please refer to cryoCARE official instructions. <br>

*For 2D stacks comprising of >50 fractions(frames) with additional adjustments, please follow the 1-generateEVENODD.sh and 2-generateTomo.sh scripts to generate both tomograms.



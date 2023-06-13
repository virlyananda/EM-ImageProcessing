## **Generating Even and Odd Tomogram** ##

Author: Virly Y. Ananda <br>
Affiliation: Department of Molecular Biology, Massachusetts General Hospital <br>
Date: 06/13/2023

Aligning 2D stacks after fractions(frames) acquisitions can be processed differently on whether the data needs further adjustments (e.g., *image size*, *pixel size*, *excluded views*, etc.) before proceeding to 3D reconstructions.

We implemented 2D stacks alignment with **IMOD** and split our fractions with ***alignframes*** which we embedded onto our bash scripts.

### **Align Even and Odd 2D Stacks** ###

<img width="710" alt="Screenshot 2023-06-13 at 2 07 14 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/484ce348-8cdf-4ff3-ae42-2fd809e1d719">

<br>

**Walkthrough**

On terminal, simply run like the example shown below: <br>

**bash GenerateStacks.sh** **-m** cryoCARE.mdoc **-s** stack_MC.mrc **-b** 8,2 **-g** /store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/PaulaNavarro_20220908_PAU_3/GainsBackup2022-09-08/gain_flipx.dm4 **-o** output_test **-S** 5760,4092 **-p** 2.705,2.705,2.705 **-I** /store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/Fractions/L12_Pos1/imod **-M** stack_MC

### **Construct Even and Odd Tomograms** ###

<img width="735" alt="Screenshot 2023-06-13 at 3 14 48 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/219425fc-ce97-44a7-826c-766dce9c1804">

**Walkthrough**

Before executing this script, make sure all the supporting metafiles (.xf, .xtilt, .tlt) and parameters files (eraser.com, eraser.com, and tilt.com) are present in both even/odd directories.
In our procedure, the content of each parameters files were adjusted (e.g., stack names, sizes, mode, etc.) before executing this step.

*For 2D stacks comprising of >50 fractions(frames) with additional adjustments, please follow the 1-generateEVENODD.sh and 2-generateTomo.sh scripts to generate both tomograms.



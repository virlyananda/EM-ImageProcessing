## **Generating Even and Odd Tomogram** ##

Author: Virly Y. Ananda <br>
Affiliation: Department of Molecular Biology, Massachusetts General Hospital <br>
Date: 06/13/2023

Aligning 2D stacks after fractions(frames) acquisitions can be processed differently on whether the data needs further adjustments (e.g., *image size*, *pixel size*, *excluded views*, etc.) before proceeding to 3D reconstructions.

We implemented 2D stacks alignment with **IMOD** and split our fractions with ***alignframes*** which we embedded onto our bash scripts.

<img width="710" alt="Screenshot 2023-06-13 at 2 07 14 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/484ce348-8cdf-4ff3-ae42-2fd809e1d719">

<br>
***Walkthrough*** <br>

On terminal, simply run like the example shown below: <br>

**bash GenerateStacks.sh** **-m** cryoCARE.mdoc **-s** stack_MC.mrc **-b** 8,2 **-g** /store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/PaulaNavarro_20220908_PAU_3/GainsBackup2022-09-08/gain_flipx.dm4 **-o** output_test **-S** 5760,4092 **-p** 2.705,2.705,2.705 **-I** /store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/Fractions/L12_Pos1/imod **-M** stack_MC

## **Generating Even and Odd Tomograms** ##

Author: Virly Y. Ananda <br>
Affiliation: Department of Molecular Biology, Massachusetts General Hospital <br>
Date: 06/13/2023

### Cryo-Electron Tomography (ET) Image Processing
---------
This is a walkthrough on implementing cryoCARE deep learning tomogram denoising acquired from MIT Krios which are then processed at the Chao Lab. <br>

**Requirements** <br>
1. NVIDIA GPUs + CUDA 11
2. Anaconda (or Miniconda)
3. IMOD (3DMOD) <br>

---------
## Prepare Processing Directory
**Please skip **Step 1** and **Step 2** if you are a Chao Lab member.*
#### Step 1: Install Anaconda <br>
Source: https://docs.anaconda.com/free/anaconda/install/linux/ <br>

#### Step 2: Set up cryoCARE Environment <br>
``````
conda create -n cryocare_11 python=3.8 cudatoolkit=11.0 cudnn=8.0 -c conda-forge
conda activate cryocare_11
pip install tensorflow==2.4
pip install cryoCARE
``````
#### Step 3: Activate cryoCARE Environment <br>
``````
# Activate anaconda that has been installed:
source /store0/python_envs/anaconda3/bin/activate

# Activate cryocare_11 conda environment:
conda activate cryocare_11
``````
#### Step 4: Create a directory to store image processing scripts <br>
```
# Create a directory
mkdir -p cryoCARE-Processing

# Go to working directory
cd cryoCARE-Processing
```
Store cryocare supporting files and customized script for generating even and odd tomograms into this directory. <br>

**cryoCARE-Processing** directory must have these files (Request to Virly): <br>
1. 2-generateODDEVEN.sh
2. 3-alignStack.sh
3. 4-generateTomo.sh
4. cryocare
5. train_data_config.json
6. train_config.json
7. predict_config.json <br>

Now that we have the supporting files ready, we can proceed on generating even and odd tomograms. <br>

---
## Generating Even and Odd Tomograms
#### Step 1: Organize working directory <br>

<img width="310" alt="Screenshot 2023-07-21 at 3 32 21 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/689d15d3-471c-4cf4-8037-d130cd01f6d3"> <br>

Figure 1. Example of how the directories before processing are organized. <br>

#### Step 2: Adjust cryoCARE.mdoc <br>
Under the fractions directory where your original .MDOC file is located, copy orignal .MDOC file and rename it as cryoCARE.mdoc.

```
# Create a copy of the .mdoc file where we can adjust the setting without compromising the original .mdoc file.
cp L1_Pos1.mdoc cryoCARE.mdoc
```

```
# Adjust cryoCARE.mdoc
vim cryoCARE.mdoc
```
Press **i** to edit the file content. Change the parameters as shown below: <br>

**DataMode = 2** <br>
**ImageFile = stack_MC_cc.mrc** <br>

Once adjusted, press **Esc** then **:x**, hit **Enter**. This will save the adjusted file.

#### Step 3: Generate Odd and Even Stacks <br>
```
bash 2-generateODDEVEN.sh
```
This will prompt questions:
```
Your working directory containing raw fractions (with cd):
cd /store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/Fractions/L1_Pos2/fractions

# Adjusted .mdoc file.
Provide .mdoc file: 
cryoCARE.mdoc

# This is the stack name you put on cryoCARE.mdoc file.
Provide output file:
stack_MC_cc.mrc

# Binning size
Provide binning size (2 int): 
8,2

# Full path to gain reference
Provide gain reference: 
/store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/PaulaNavarro_20220908_PAU_3/GainsBackup2022-09-08/gain_flipx.dm4

# This will create a directory to store original aligned stacks.
Output directory:
output_test

#### Generating and splitting stacks ####

#### **Check fractions order** (go to even and odd directories and adjust sorting if needed before proceeding) ####

Output stack size in X and Y (X,Y):
5760,4092

# Pixel spacings for aligned stacks
Output pixel size in Angstrom (X,Y,Z):
2.705, 2.705, 2.705

Would you like to exclude other views in even/odd stack? (Yes/No) 
Yes

# Excluding stacks: Start with 1 (if any)
Which views would you like to exclude? 
1-5

# You may open other tab to see if even and odd stacks have been processed.

# Copying IMOD supporting files
Provide your IMOD files location:
/store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/Fractions/L1_Pos2/imod

# This is the repetitive name you see on .xtilt, .tlt and .xf 
Provide your stack name from IMOD (no extension): 
stack_MC
```

**Step 4: Copy IMOD supporting files (if IMOD files haven't been transferred yet** <br>

```
# On terminal run this:

bash 3-alignStack.sh
```
This will prompt questions:

```
Your working directory: 
cd /store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/Fractions/L1_Pos2/fractions

Provide your IMOD files location: 
/store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/Fractions/L1_Pos2/imod

# This is the repetitive name you see on .xtilt, .tlt and .xf from your IMOD (do not use fiducial ones)
Provide your stack name from IMOD:
stack_MC
```
### Please check eraser.com, and adjust the parameters in newst.com and tilt.com ###

1. **Check eraser.com** <br>
Inside **even** and **odd** directories: <br>

    On terminal, run **vim eraser.com** or **vi eraser.com** <br>

    <img width="596" alt="Screenshot 2023-07-21 at 4 03 27 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/2eaa8904-b91b-4705-adda-0970a16aa431"> <br>

    Once adjusted, save the file by pressing **Esc** then **:x**

2. **Adjust newst.com** <br>
    Inside **even** and **odd** directories: <br>

    On terminal, run **vim newst.com** or **vi newst.com** <br>

    Press **i** to edit the file. <br>

     <img width="455" alt="Screenshot 2023-07-21 at 3 48 58 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/5d42c607-651b-482e-9813-adb4e9606f8e"> <br>
     
    Once adjusted, save the file by pressing **Esc** then **:x**


3. **Adjust tilt.com** <br>

    Inside **even** and **odd** directories: <br>

    On terminal, run **vim tilt.com** or **vi tilt.com** <br>

    Press **i** to edit the file. <br>
    
<img width="673" alt="Screenshot 2023-07-21 at 3 54 53 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/f0cf26a6-68cf-476d-b83e-8d178a463bec"> <br>

  Once adjusted, save the file by pressing **Esc** then **:x** <br>

**Make sure no to change the parameters that are not specified as shown above.**

**Step 5: Generate 3D Reconstructions on Even and Odd Aligned Stacks** <br>

```
# On terminal run this

bash 4-generateTomogram.sh
```
This will prompt questions:
```
Your working directory:
cd /store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/Fractions/L1_Pos2/fractions

# For even
Would you like to rotate even tomogram? (Yes/No)
Yes

# The unrotated tomo name from tilt.com (even tomogram)
Provide the name of current even tomogram (with extension):
stack_MC_full_rec.mrc

# The rotated tomogram name in .rec (create your own for even tomogram)
Provide the name of the final even tomogram (with extension): 
bin4_rotTomo_even.rec

# For odd
Would you like to rotate even tomogram? (Yes/No)
Yes

# The unrotated tomo name from tilt.com (for odd tomogram)
Provide the name of current even tomogram (with extension):
stack_MC_full_rec.mrc

# The rotated tomogram name in .rec (create your own for odd tomogram)
Provide the name of the final even tomogram (with extension): 
bin4_rotTomo_odd.rec
```
**And you're all set for tomogram pre-processing!** <br>

*It's frustrating at first sorry...*

## Even and Odd Tomograms into cryoCARE <br>
---
You can always refer to the original documentation here: https://github.com/juglab/cryoCARE_pip <br>

The following parameters shown below were used for our local tomograms.
<br>

**Step 1: Normalize Dataset** <br>

Open and edit **train_data_config.json** file <br>
```
vim train_data_config.json
```
Press **i** to edit the file: <br>

```
{
  "even": [
    "/store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/Fractions/L1_Pos2/fractions/even/bin4_rotTomo_even.rec"
  ],

  "odd": [
    "/store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/Fractions/L1_Pos2/fractions/odd/bin4_rotTomo_odd.rec"
  ],
  "patch_shape": [
    72,
    72,
    72
  ],
  "num_slices": 1200,
  "split": 0.9,
  "tilt_axis": "Y",
  "n_normalization_samples": 500,
  "path": "./corynie/L1Pos2/dataset_V1/",
  "overwrite": "True"
}
```
Press **Esc** then **:x** , hit **Enter** to save adjusted file. <br>

On terminal, run normalization: <br>
```
cryoCARE_extract_train_data.py --conf train_data_config.json
```


You should see a progress bar after normalization is done. <br>

If sucessful, under *corynie/L1Pos2/dataset_V1/* , you will see 2 **.npz** files (training and validation). These files will be used for the second step shown below.

**Step 2: Train Dataset** <br>

Open and edit **train_config.json** file: <br>
```
{
  "train_data": "./corynie/L1Pos2/dataset_V1/",
  "epochs": 100,
  "steps_per_epoch": 200,
  "batch_size": 16,
  "unet_kern_size": 3,
  "unet_n_depth": 3,
  "unet_n_first": 16,
  "learning_rate": 0.0004,
  "model_name": "model_V1",
  "path": "./corynie/L1Pos2/model_V1/",
  "overwrite": "True",
  "gpu_id": 0

}
```
Press **Esc** then **:x** , hit **Enter** to save adjusted file. <br>

On terminal, run training (this will take a few hours): <br>
```
cryoCARE_train.py --conf train_config.json
```

*You can always adjust the GPU ID*. <br>

**Step 3: Predict Dataset (Denoising)** <br>
This is the last step in performing denoising. Once training is finished, follow the steps below: <br>

Open and edit **predict_config.json** file: <br>
```
vim predict_config.json
```
Press **i** to edit the file: <br>
```
{
  "path": "./corynie/L1Pos2/model_V1/model_V1.tar.gz",
  "even": "/store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/Fractions/L1_Pos2/fractions/even/bin4_rotTomo_even.rec",
  "odd": "/store0/navarro/data/raw/tomography/cryo-FIB/bacteria/corynie/Fractions/L1_Pos2/fractions/odd/bin4_rotTomo_odd.rec",
  "n_tiles": [1,1,1],
  "output": "./corynie/L1Pos2/denoised_V1/",
  "overwrite": "True",
  "gpu_id": 0

}
```
Press **Esc** then **:x** , hit **Enter** to save adjusted file. <br>

On terminal, run prediction (this will take ~20min. depending on how thick your tomogram is): <br>

```
cryoCARE_predict.py --conf predict_config.json
```
Final prediction of the restored tomogram can be found in corynie/L1Pos2/denoised_V1/ . <br>

Notice that you'll be getting **even** tomogram name under denoised folder, you can rename this as this is a small bug that happened each time. <br>

### ALTERNATIVE SCRIPTS (STILL BEING DEVELOPED, NOT READY YET, SO USE THE ONES ABOVE!)

**Main Steps on Generating a Tomogram**:
* **2D Stacks Alignment**: This is where a list of .TIFF formatted fractions are generated into 2D stacks which then can be aligned accordingly. Certain views can be excluded in this phase.
* **3D Reconstruction**: This is where tomogram is generated from the aligned 2D stacks.
<br>

Aligning 2D stacks after fractions(frames) acquisitions can be processed differently on whether the data needs further adjustments (e.g., *image size*, *pixel size*, *excluded views*, etc.) before proceeding to 3D reconstructions.

We implemented 2D stacks alignment with **IMOD** and split our fractions with ***alignframes*** which we embedded onto our bash scripts.

### **Align Even and Odd 2D Stacks** ###

<img width="710" alt="Screenshot 2023-06-13 at 2 07 14 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/1ca6bcf8-8caa-48e5-bddc-cd1a73f616f9">

<br>

#### **Walkthrough** #### 

**Step 1**: Go to the directory where your IMOD file and .TIFF fractions are stored. <br>
**Step 2**: Run the script on terminal, simply run like the example shown below: <br>

**bash GenerateStacks.sh** **-m** [mdocfile].mdoc **-s** [stackname].mrc **-b** 8,2 **-g** [gainreffile].dm4 **-o** [output_directory] **-S** [sizeY,sizeX] **-p** [A,A,A] **-I** [pathwaytoIMODfile] **-M** [imodfilenames]

Please refer to **alignframes** website to check further information on the parameters.

### **Construct Even and Odd Tomograms** ###

<img width="742" alt="Screenshot 2023-06-14 at 8 30 02 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/1b2907f5-1c27-4916-8e25-b5e797e2e5f1">

#### **Walkthrough** #### 

**Step 1**: Confirm you have the original metafile copied to both even and odd directories.
  * Metafiles: .xf, .xtilt, .tlt (these files contain necessary rotations information)
  * Parameter files: The .com files such as eraser.com, newst.com and tilt.com (these files contain necessary parameters to align and generate tomogram).<br>
**Step 2**: Update necessary information within the .com files. Normally, adjustment in stack output names, tomogram names, GPU usage, mode, and stack sizes must be checked. Mode should be 2 (floating-type). <br>
**Step 3**: Check whether your tomogram should be rotated. If so, you may continue. <br>
**Step 4**: Run the script to generate even and odd tomograms. <br>
**Step 5**: Feed even and odd tomograms to cryoCARE scripts. Please refer to cryoCARE official instructions. <br>

*For 2D stacks comprising of >50 fractions(frames) with additional adjustments, please follow the 1-generateEVENODD.sh and 2-generateTomo.sh scripts to generate both tomograms.



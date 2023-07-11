# Electron Microscopy (EM) Image Processing #

## Cryo-Electron Tomography (ET) ##
Authors: Virly Y. Ananda, Paula P. Navarro<br>Date: 06/09/2023<br>Affiliation: Massachusetts General Hospital, Department of Molecular Biology

<img width="665" alt="Screenshot 2023-06-13 at 9 04 40 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/51f87257-b5be-490f-b933-9cf8ef5519b0">

Cryo-Electron Tomography (ET) is a subfield of Cryo-Electron Microscopy (EM) where images are tilted during acquisition to form a three-dimensional visualization of the specimen. While this technique has been around to study organelles biological formations in native condition, volume images (tomogram) produced by Cryo-ET also came with major issues that limit our interpretation of the data. However, due to certain side effects caused during image acquisition, additional computational processing are necessary to obtain accurate analysis.

This documentation provides a complete walkthrough on how volume images (tomogram) are processed to efficiently generate 3D surface of regions of interest after image acquisitions are performed.


Limitation  | Solution
------------- | -------------
Low-SNR  | cryoCARE
Laborious Segmentation  | Amira (Pixel-based Classification)

**Hardware Requirements***
* GPUs with NVIDIA CUDA platform
* Linux OS

**Software Requirements***
* IMOD(3DMOD) [1]
* cryoCARE [2]
* isoNET (Optional) [3]
* Amira ThermoFisher [4]
* MATLAB (Dynamo) [5]
* ChimeraX (ArtiaX) [6]
* TomoSegMemTV [7]
* Conda environment (Python 3.8 or above) [8]

******

### **Step 1: Volume Image (Tomogram) Restoration** ###

### ***General Procedure*** ##
Before generating volume images (tomogram), fractions (frames) are normally acquired from the microscope by tilting the sample in certain angles. These fractions are then processed through 3D reconstruction software (IMOD) in order to produce a tomogram.

<img width="807" alt="Screenshot 2023-06-12 at 10 33 14 AM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/81f60e05-06a9-4696-acab-2e3a69f1060d">

***Figure 1. General 3D reconstruction procedure.***
Common procedure done after 3D reconstructions (tomogram) were performed. Additional filtering (denoising) is applied after tomogram has been generated.
*Source: Virly Y. Ananda*

The pipeline shown above is commonly used when no training is involved during pre-processing. Normally, tomogram produced by such procedure would result in integer image (tomogram) type data.

We performed transfer learning based denoising platform from Topaz where pre-model has been trained. As a result, we only needed to input our original tomogram into the program for Topaz to predict the denoised (restored) tomogram.

### ***Our Procedure*** ###
We optimized the general procedure to obtain more accurate results for our dataset. To avoid beam-based contrast that causes bias when frames are transferred digitally, fractions (frames) were split into halves where even and odd signals can be separated.

These even and odd fractions were then aligned and reconstructed to produce its corresponded tomogram. As a result, we feed cryoCARE image restoration training with localized unbiased even and odd tomograms.

<img width="918" alt="Screenshot 2023-06-12 at 10 24 51 AM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/f29f5e67-d9e5-421c-a594-143b1ea3c875">

***Figure 2. In-house tomogram restoration pipeline.*** Frames (fractions) were generated in full and were later split into even and odd. Even and odd 2D stacks were then aligned and 3D reconstructed through IMOD. Training was performed on floating-point image (tomogram) data type.<br>
*Source: Virly Y. Ananda*

Even and odd tomograms were then feed into cryoCARE where Noise2Noise framework is applied to reduce noise from each tomogram. The program would then construct a finalized tomogram with the most reduced noise.

**Comparison of Tomogram Restoration**

***Figure 3. Comparison of tomogram restorations through machine learning-based denoising platform.***(Left) Topaz Denoise3D prediction, (middle) raw tomogram, and (right) cryoCARE prediction. Tomograms were binned by 4.
*Tomogram Acquisition: Paula P. Navarro*

<img width="870" alt="Screenshot 2023-06-14 at 8 14 06 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/51dd5a73-645a-4103-8e06-41ede9ebbb73">

Based on both predicted models, we noticed cryoCARE seems to show a more normalized contrast where ROIs are highlighted and background seems to be dampened. Topaz on the other hand seems to show high intensity of contrast on ROIs and certain artifacts while background is dampened as well.

Depending on how the data is being processed and analyzed onward, Topaz is recommended if only tomogram visualization is prioritized and low on computational power. However, cryoCARE training is recommended if further processing will be performed such as template matching and auto-segmentation.

Platform  | Running Time | Platform | Image (Data) Type
------------- | ------------- | ------------ | -------
Topaz Denoise3D | 30 min. (Prediction only) | Transfer learning | Floating point (IMOD: Mode 2)
cryoCARE  | ~3 hrs. (Training and prediction) | Training from scratch | Floating point (IMOD: Mode 2)

**Both platforms utilize UNET Noise2Noise framework.*
**Training performance depends on GPUs condition.* <br>
**Computational hardware used: **NVIDIA GeForce GTX 1080 Ti with CUDA 11.4.***

### **Step 2: Tomogram Segmentation (Object Classification)** ###
To generate 3D renderings of ROIs, segmentations are normally performed to partition objects on tomogram based on their pixel characteristics. Considering the large size of a tomogram, several types of segmentations can be performed based on the objects being analyzed.<br>

#### **Types of Segmentations** ####
**A. Semantic Segmentations**: Classify objects by the average value of their pixel characteristics. <br>

<img width="662" alt="Screenshot 2023-06-12 at 3 04 59 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/9dc8130e-9762-4652-8624-87f476d6868c">

***Figure A. Objects are manually hand-segmented (traced) to classify each label.*** This procedure was repeated on 3 slices out of 249 slices on cryoCARE predicted restored tomogram.

***Figure B. Train the manually segmented labels on Amira.*** Patch size was adjusted to 64x64 for training purposes. Bounding boxes were placed on the area where one label can be seen with other labels, as well as on the background where no label is present. Training was done individually for each label (e.g., Inner Membrane, Outer Membrane, and Peptidoglycan). <br> *Tomogram Acquisition: Paula P. Navarro*

***Figure C. Semantic segmentation prediction on Amira.*** With only manually segmenting 3 out of 249 slices, our model prediction seems to segment (classify) other areas that weren’t manually segmented.

***Figure D. Outer membrane (OM) predicted segmentation.***<br>
Automated tracing were shown as a result of predicted segmentation. Based on the result, we could see it was able to correctly trace the outer membrane area.

***Figure E. Segmented prediction all objects.*** As we generate 3D surface of all the segmented slices on the tomogram, we found only a few false positives and false negatives. These outliers were later refined by implementing lasso deletion across slices and manual tracing to fill out the false negatives.

**B. Threshold-based Segmentation:** Classifying objects based on pixel intensity level.

<img width="737" alt="Screenshot 2023-06-12 at 3 06 09 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/ed01ced2-ae6e-41e6-bf8b-d26d37d4e230">

***Figure 9. Auto-thresholding segmentation.*** TomoSegMemTV was performed to detect membranous areas on cryoCARE predicted tomogram. TomoSegMemTV, a toolkit designed to perform object detection by utilizing Tensor Voting algorithm was able to detect higher intensity areas while discarding the rest by adjusting thresholding values.

**C. Manual Segmentation:** Classifying objects manually by hand tracing.<br>

<img width="424" alt="Screenshot 2023-06-14 at 8 10 35 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/15d99b80-e0f4-4f8e-9fc1-21af3aea8f05">

***Figure 10. Manual segmentation in refining 3D surfaces.*** Mitochondrial sub-compartments (inter membrane space in pink, crista lumen in magenta, and matrix in translucent grey). Manual segmentation is normally done on every 5 slices to maximize tracing interpolation across Z stacks. Surfaces were then generated, triangulations simplified, re-meshed, and smoothened on Amira.

Manual segmentation timeline is context-dependent. We noticed tomograms with more artifacts due to sample preparation issues required more time-consuming manual hand segmentations and refinement.

Platform  | Segmentation Time | Refinement Time |
------------- | ------------- | ------------ |
Amira pixel-based classifier | ~15min/tomogram | ~20 min/tomogram |
TomoSegMemTV  | ~1hr/tomogram | ~1 hr/tomogram |
Manual segmentation | ~5hr/tomogram | ~30 min/tomogram

**Refinement Method** <br>

<img width="748" alt="Screenshot 2023-07-09 at 11 49 21 AM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/8fe56f89-5399-4ad0-9847-31e18a586feb">


Our refinement method is described as follows: <br>
* **Segmentation Label(s)**: This is normally a 2D binary format where objects are classified on each slices of the tomogram. You may adjust various sizes and coordinates with this file on any 3D visualization software. Once sizes and coordinates are adjusted, you can generate this as 3D surface(volume rendering).
*  **Manual Refinement**: Manual refinement is where you hand trace any missing object undetected by auto-segmentation with a tablet pen. This might be time-consuming depending on the condition of your original segmentation. Normally, manual refinement is done after auto-segmentation through TomoSegMemTV or Amira Pixel-based segmentation.
*  **Simplify Triangulation**: To minimize the size our 3D surfaces, we simplify triangulation on Amira. Because finalized 3D surface comprises of triangulations which determine points in 3D space, adjusting this could affect the size of our surface models. This could affect the volume measurement on your surface models.
*  **Remesh Triangulation**: To create a mesh out of the re-adjusted triangulations, we selected remesh on Amira. 
*  **Smooth Triangulation Mesh**: To improvise our surfaces features, we performed smoothing on Amira. This is for visualization purposes.

## **3D Surfaces/Renderings on Single Particle and Electron Tomography ##
A 3D surface (rendering) comprises of triangulation faces that made up 3D projection. Because it is a finalized model, it would be difficult to adjust coordinates or sizes when viewed on other 3D softwares.

To avoid this problem, we recommend to always use the label formats to adjust any coordinates/sizes.

**Viewing Surface on other 3D software** <br>
Convert surfaces to .STL or .obj format.

**Viewing Labels on other 3D software/toolkits** <br>
Convert Amira labels to .MRC format.

### **Step 3: Template Matching (Ribosome Localization)** ###
Locating macromolecules such as ribosome can be done on a tomogram. We performed template matching on a single-particle (SP) cryo-EM ribosome on one of our tomograms through MATLAB-based Dynamo platform.


Data | Description | Voxel Size
----------|-------------|-----------
Ribosome | EMD-2847 | 0.75525 Å
Tomogram | Ecoli WT | 10.26 Å

<img width="854" alt="Screenshot 2023-06-12 at 4 04 06 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/ea4e8f97-0012-42ec-a752-52654e4e9264">
 
***Figure 12. Visualization objective.*** 
Target pipeline for implementing template matching where 3D surface of ribosome can be merged with membranes 3D surfaces.

In this process, we utilized several 3D software tools for bio-imaging analysis such as Amira, ChimeraX(ArtiaX), MATLAB-Dynamo scripts to integrate the overall models. <br>

**Customized Ribosome Localization Pipeline**
<br>
<img width="977" alt="Screenshot 2023-07-09 at 1 03 07 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/298b1b40-cd5a-4299-bfd1-b5afa9b506d9">
<br>

**Software Tools/Packages Usage** <br>
* **Amira**: Amira 3D Pro ThermoFisher was used to segment and refine(smooth) 3D surfaces of the cell envelope areas on our tomogram.
*  **Dynamo(MATLAB)**: Dynamo Biozentrum, a cryo-tomography analysis package(also available on standalone) is used for particle picking and detection.
*  **ChimeraX(ArtiaX)**: Final visualization of all models were done here. <br>

**Warning** <br>
Generating .STL file produces large size of data which could cause memory corruption. To avoid this issue, we only generated .STL files for 3D renderings that could be simplified such as cell envelopes and other membrane regions. As for ribosomes, it is best to save table (.tbl) format from Dynamo (MATLAB) containing the correct X,Y,Z coordinates (which you can view on ChimeraX). You may use ChimeraX (ArtiaX) to merge segmentations and ribosome 3D surfaces.

**Supporting scripts and walkthrough documentation can be viewed in corresponding files above.** <br>

<br>

**Customized Complete Pipeline**
 <br>

![Cryo-ET-customized-pipelinevya](https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/508adccd-bd41-4055-a43a-fb37d1f16972)
 <br>

**Due to the on going process of the publications, most of the results can only be accessed by request. Please request Virly on the most updated results of the pipeline.**

# Transmission Electron Microscopy (TEM) Object Detection #

Authors: Virly Y. Ananda<br>Date: 06/13/2023<br>Affiliation: Massachusetts General Hospital, Department of Molecular Biology <br>

**Transmission Electron Microscopy (TEM)** is a microscopy technique in which electron of beam passes through the sample in order to obtain a projection of a specimen. This has become the most fundamental technique in the EM community to better understand how basic EM works.
<br>

Here we provide a walkthrough on detecting objects such as vesicles on 2D TEM images. The images shown in this documentation are based on negative-stained samples of Prominin-1 (Prom1, CD133) extracellular vesicles and Tweety-homolog1 (Tthy1) vesicles. <br>

**Objective** <br>
Detect targeted vesicles on uneven shades of background of negative-stained images and measure vesicles morphology across hundreds of images. <br>

![TEM-vesicle-pipeline-v2](https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/de0dfbe5-878b-46e5-9e44-0be002338ee4)

 <br>
 <br>
 <br>
 
![vesicle-pipelinev3](https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/e93e743c-00ea-4595-86be-90cc361ff5ce)

Figure 1. Current probability of targeted vesicles in yellow, artifacts in red, and background in blue. Images were classified after background subtraction based on **Rolling Ball Algorithm** with a radius of 95 is implemented.

**Prospect**: More training dataset required to implement batch predict on testing dataset. False positives (grid background wrinkles can be seen around vesicles area in yellow) should be decreased (eliminated if possible). This is an on-going work...

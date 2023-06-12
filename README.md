# Cryo-Electron Tomography (ET) Image Processing #
Authors: Virly Y. Ananda, Paula P. Navarro<br>Date: 06/09/2023<br>Affiliation: Massachusetts General Hospital, Department of Molecular Biology

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

<img width="807" alt="Screenshot 2023-06-12 at 10 33 14 AM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/e8bfca57-737a-48d7-8e36-27d1055e95f5">

***Figure 1. General 3D reconstruction procedure.***
Common procedure done after 3D reconstructions (tomogram) were performed. Additional filtering (denoising) is applied after tomogram has been generated.
*Source: Virly Y. Ananda*

The pipeline shown above is commonly used when no training is involved during pre-processing. Normally, tomogram produced by such procedure would result in integer image (tomogram) type data.

We performed transfer learning based denoising platform from Topaz where pre-model has been trained. As a result, we only needed to input our original tomogram into the program for Topaz to predict the denoised (restored) tomogram.

### ***Our Procedure*** ###
We optimized the general procedure to obtain more accurate results for our dataset. To avoid beam-based contrast that causes bias when frames are transferred digitally, fractions (frames) were split into halves where even and odd signals can be separated.

These even and odd fractions were then aligned and reconstructed to produce its corresponded tomogram. As a result, we feed cryoCARE image restoration training with localized unbiased even and odd tomograms.

<img width="918" alt="Screenshot 2023-06-12 at 10 33 53 AM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/d269465b-3bff-46e4-8d59-e0719d595c1a">

***Figure 2. In-house tomogram restoration pipeline.*** Frames (fractions) were generated in full and were later split into even and odd. Even and odd 2D stacks were then aligned and 3D reconstructed through IMOD. Training was performed on floating-point image (tomogram) data type.<br>
*Source: Virly Y. Ananda*

Even and odd tomograms were then feed into cryoCARE where Noise2Noise framework is applied to reduce noise from each tomogram. The program would then construct a finalized tomogram with the most reduced noise.

**Comparison of Tomogram Restoration**

***Figure 3. Comparison of tomogram restorations through machine learning-based denoising platform.***(Left) Topaz Denoise3D prediction, (middle) raw tomogram, and (right) cryoCARE prediction. Tomograms were binned by 4.
*Tomogram Acquisition: Paula P. Navarro*
<img width="1363" alt="Screenshot 2023-06-09 at 9 12 30 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/2c918b2c-4e4f-4cbe-b40f-79b354f066e2">

Based on both predicted models, we noticed cryoCARE seems to show a more normalized contrast where ROIs are highlighted and background seems to be dampened. Topaz on the other hand seems to show high intensity of contrast on ROIs and certain artifacts while background is dampened as well.

Depending on how the data is being processed and analyzed onward, Topaz is recommended if only tomogram visualization is prioritized and low on computational power. However, cryoCARE training is recommended if further processing will be performed such as template matching and auto-segmentation.

Platform  | Running Time | Platform | Image (Data) Type
------------- | ------------- | ------------ | -------
Topaz Denoise3D | 30 min. (Prediction only) | Transfer learning | Floating point (IMOD: Mode 2)
cryoCARE  | ~3 hrs. (Training and prediction) | Training from scratch | Floating point (IMOD: Mode 2)

**Training performance depends on GPUs condition.* <br>
**Computational hardware used: **NVIDIA GeForce GTX 1080 Ti with CUDA 11.4.***

### **Step 2: Tomogram Segmentation (Object Classification)** ###
To generate 3D renderings of ROIs, segmentations are normally performed to partition objects on tomogram based on their pixel characteristics. Considering the large size of a tomogram, several types of segmentations can be performed based on the objects being analyzed.<br>

#### **Types of Segmentations** ####
**A. Semantic Segmentations**: Classify objects by the average value of their pixel characteristics. <br>

<img width="662" alt="Screenshot 2023-06-12 at 3 04 59 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/8ab683a4-9b8d-4ea3-8d37-e12ea4465930">

***Figure A. Objects are manually hand-segmented (traced) to classify each label.*** This procedure was repeated on 3 slices out of 249 slices on cryoCARE predicted restored tomogram.

***Figure B. Train the manually segmented labels on Amira.*** Patch size was adjusted to 64x64 for training purposes. Bounding boxes were placed on the area where one label can be seen with other labels, as well as on the background where no label is present. Training was done individually for each label (e.g., Inner Membrane, Outer Membrane, and Peptidoglycan). <br> *Tomogram Acquisition: Paula P. Navarro*

***Figure C. Semantic segmentation prediction on Amira.*** With only manually segmenting 3 out of 249 slices, our model prediction seems to segment (classify) other areas that weren’t manually segmented.

***Figure D. Outer membrane (OM) predicted segmentation.***<br>
Automated tracing were shown as a result of predicted segmentation. Based on the result, we could see it was able to correctly trace the outer membrane area.

***Figure E. Segmented prediction all objects.*** As we generate 3D surface of all the segmented slices on the tomogram, we found only a few false positives and false negatives. These outliers were later refined by implementing lasso deletion across slices and manual tracing to fill out the false negatives.

**B. Threshold-based Segmentation:** Classifying objects based on pixel intensity level.

<img width="737" alt="Screenshot 2023-06-12 at 3 06 09 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/6bdd8509-4ba2-41aa-844f-5481f6de8d67">

***Figure 9. Auto-thresholding segmentation.*** TomoSegMemTV was performed to detect membranous areas on cryoCARE predicted tomogram. TomoSegMemTV, a toolkit designed to perform object detection by utilizing Tensor Voting algorithm was able to detect higher intensity areas while discarding the rest by adjusting thresholding values.

**C. Manual Segmentation:** Classifying objects manually by hand tracing.<br>

<img width="427" alt="Screenshot 2023-06-12 at 3 01 41 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/c624670a-6963-482a-9f3a-0736b509e5e5">

***Figure 10. Manual segmentation in refining 3D surfaces.*** Mitochondrial sub-compartments (inter membrane space in pink, crista lumen in magenta, and matrix in translucent grey). Manual segmentation is normally done on every 5 slices to maximize tracing interpolation across Z stacks. Surfaces were then generated, triangulations simplified, re-meshed, and smoothened on Amira.

Manual segmentation timeline is context-dependent. We noticed tomograms with more artifacts due to sample preparation issues required more time-consuming manual hand segmentations and refinement.

Platform  | Segmentation Time | Refinement Time |
------------- | ------------- | ------------ |
Amira pixel-based classifier | ~15min/tomogram | ~20 min/tomogram |
TomoSegMemTV  | ~1hr/tomogram | ~1 hr/tomogram |
Manual segmentation | ~5hr/tomogram | ~30 min/tomogram

**Refinement Method** <br>

<img width="979" alt="Screenshot 2023-06-12 at 3 13 53 PM" src="https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/6100c483-d61a-4195-823e-fe65e4eeee11">

Our refinement method is described as follows: <br>
* **Segmentation Label(s)**: This is normally a 2D binary format where objects are classified on each slices of the tomogram. You may adjust various sizes and coordinates with this file on any 3D visualization software. Once sizes and coordinates are adjusted, you can generate this as 3D surface(volume rendering).
*  **Manual Refinement**: Manual refinement is where you hand trace any missing object undetected by auto-segmentation with a tablet pen. This might be time-consuming depending on the condition of your original segmentation. Normally, manual refinement is done after auto-segmentation through TomoSegMemTV or Amira Pixel-based segmentation.
*  **Simplify Triangulation**: To minimize the size our 3D surfaces, we simplify triangulation on Amira. Because finalized 3D surface comprises of triangulations which determine points in 3D space, adjusting this could affect the size of our surface models. This could affect the volume measurement on your surface models.
*  **Remesh Triangulation**: To create a mesh out of the re-adjusted triangulations, we selected remesh on Amira. 
*  **Smooth Triangulation Mesh**: To improvise our surfaces features, we performed smoothing on Amira. This is for visualization purposes.

## **3D Surface (Rendering)** ##
A 3D surface (rendering) comprises of triangulation faces that made up 3D projection. Because it is a finalized model, it would be difficult to adjust coordinates or sizes when viewed on other 3D softwares.

To avoid this problem, we recommend to always use the label formats to adjust any coordinates/sizes.

**Viewing Surface on other 3D software** <br>
Convert surfaces to .STL or .obj format.

**Viewing Labels on other 3D software/toolkits** <br>
Convert Amira labels to .MRC format.>

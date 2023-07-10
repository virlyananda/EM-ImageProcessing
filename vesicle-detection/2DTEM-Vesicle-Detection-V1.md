## 2D TEM: Vesicles Detection ##
Authors: Virly Y. Ananda, Tristan A. Bell <br>
Date: 07/10/2023 <br>
Affiliation: Massachusetts General Hospital, Department of Molecular Biology (Chao Lab) <br>

### Evaluation on Pre-Processed Image Segmentations
-----
Implementing object detection on 2D TEM images can be challenging due to complex features of the region of interests (ROIs). This is because most of the TEM images we collected produced uneven shades on the background, and foreground features vary based on sample preparation. This documentation provides a walkthough on how we can segment out our targeted vesicles while minimizing false positives upon implementing automatic segmentation. <br>

In this section we present our current results based on batch prediction masks obtained from Ilastik trained model. <br>

The workflow we implemented is shown below: <br>

**Step 1: Pre-Process Images (FIJI)** <br>
We used FIJI to batch process background subtraction (Rolling Ball Subtraction with Radius of 95) on all TEM images under the same cell line. <br>

**Step 2: Pixel Semantic Segmentation (Ilastik)** <br>
Five most complex-looking pre-processed images were then exported to Ilastik for manual segmentations. These segmented images were used as our segmentation training model. <br>

**Step 3: Batch Predict (Ilastik)** <br>
Once we trained the model, we then batch apply this to the rest of the pre-processed images from the same cell line. This gave us masks for each images. <br>

**Step 4: Adjust Contrast (FIJI)** <br>
Due to the unstable contrast of the images, we used FIJI to adjust the contrast and convert them into binary masks. Depending on each image condition, some images might need additional watershed filtering while others do not. <br>

**Step 5: Evaluate Object (FIJI/Python Jupyter Notebook)** <br>
Here we evaluate one of the most complex predicted models. Notice how additional watershed algorithm could separate connected objects. <br>

This pipeline currently provides the most stable object detection on uneven negative-stained TEM images.


```python
import matplotlib.pyplot as plt

fig, (ax0, ax1, ax2, ax3) = plt.subplots(nrows=1,
                                    ncols=4,
                                    figsize=(8, 2.5),
                                    sharex=True,
                                    sharey=True)

raw_image = plt.imread('/store0/ananda/shared/Tristan/230630_TAB_EVs/5E/crop_tif/230630_TAB_EVs_072_crop.tif')
image = plt.imread('/store0/ananda/shared/Tristan/5E_IMG_ADJ/230630_TAB_EVs_072_crop.tif')
maskWaterShed = plt.imread('/store0/ananda/shared/Tristan/FIJI-E5-Measure/230630_TAB_EVs_072_crop_Simple-Segmentation.tif')
maskPred = plt.imread('/store0/ananda/shared/Tristan/IlastikModel-E5/230630_TAB_EVs_072_crop_Simple-Segmentation-binary.tif')

from skimage import color
overlay_Mask1 = color.label2rgb(maskWaterShed, raw_image) # Ilastik prediction + Binarization + Fill Holes + Watershed
overlay_Mask2 = color.label2rgb(maskPred, raw_image) # Ilastik prediction + Binarization

ax0.imshow(raw_image, cmap='gray')
ax0.set_title('Raw Image')
ax0.axis('off')

ax1.imshow(image, cmap='gray')
ax1.set_title('Preprocessed Image')
ax1.axis('off')

ax2.imshow(overlay_Mask1)
ax2.set_title('Mask + Watershed')
ax2.axis('off')

ax3.imshow(overlay_Mask2)
ax3.set_title('Predicted Mask Ilastik')
ax3.axis('off')

fig.tight_layout()
```


![output_2_0](https://github.com/virlyananda/EM-ImageProcessing/assets/70969092/5987be71-ac96-488e-bce7-2e1cda48b0e3)

    


Based on the results shown above, we notice Predicted Mask Ilastik seems to cover a more sensitive area without exceeding object boundary (this can be seen on the bottom part of the elongated vesicle. Conversely, we see more areas being covered by Mask + Watershed processing, resulting in false detection on small area in the background.

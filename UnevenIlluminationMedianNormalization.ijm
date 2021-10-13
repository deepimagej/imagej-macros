// ----------------------------------------------------------------------------------------------
// This macro removes the uneven illumination in an image and uses the median to normalize its
// values to the [0,1] range. Note that it is written for images of type 8-bit.
// Credits:

// - DeepImageJ team:
// 		- Reference: DeepImageJ: A user-friendly environment to run deep learning models in ImageJ,
// 			     E. Gómez-de-Mariscal, C. García-López-de-Haro, W. Ouyang, L. Donati, E. Lundberg, M. Unser, A. Muñoz-Barrutia, D. Sage,
//             	             Nat Methods 18, 1192–1195 (2021). https://doi.org/10.1038/s41592-021-01262-9
// ----------------------------------------------------------------------------------------------

// Rename the image to use it during the processing
rename("input");

// Addapt the window level
setMinAndMax(0, 255);

// Convert it into float to apply mathematical opetations
run("32-bit");

// Remove uneven illumination

// 1.Calculate the mean value to use it later
getRawStatistics(_, mean, _, _, _, _);

// 2.Duplicate the image to blur it
run("Duplicate...", "title=gaussianBlur");
selectWindow("gaussianBlur");
run("Gaussian Blur...", "sigma=99");

// 3.Subtract the illumination artifact and 
// restore the values with the mean
imageCalculator("Subtract 32-bit", "input","gaussianBlur");
run("Add...", "value=" + mean);
setMinAndMax(0, 255);
run("8-bit");

// Normalize the image using the median value
selectWindow("input");
run("Divide...", "value=255");
imMedian=getValue("Median")
imMedian = 0.5-imMedian
run("Add...", "value=" + imMedian);
setMinAndMax(0, 1);
run("Subtract...", "value=0.5");
selectWindow("gaussianBlur");
close();
selectWindow("input");



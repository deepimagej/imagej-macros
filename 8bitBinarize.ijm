// ----------------------------------------------------------------------------------------------
// This macro converts an image with float values between 0 and 1 into an 8-bit image.
// Then it calculates a binary mask given a certain threshold. 
// Credits:
// 		- Reference: DeepImageJ: A user-friendly plugin to run deep learning models in ImageJ, 
// 						     Gómez-de-Mariscal, E., García-López-de-Haro, C., Ouyang, W. et al., 
//                 Nat Methods 18, 1192–1195 (2021). https://doi.org/10.1038/s41592-021-01262-9
// ----------------------------------------------------------------------------------------------

// clip the range of values to the [0,1] range
getStatistics(_, _, min, max, _, _);
run("Subtract...", "value=" + min);
diff = max - min + 1e-20
run("Divide...", "value=" + diff);

// Convert the image to 8-bit
run("Multiply...", "value=" + 255);
setMinAndMax(0, 255);
run("8-bit");

// Threshold the output.
optimalThreshold = 159
setThreshold(0, optimalThreshold);
run("Convert to Mask");

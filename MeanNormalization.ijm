// ----------------------------------------------------------------------------------------------
// This macro projects the intensity values of an image to the [0,1] range. Then it applies a 
// mean normalization using specific mean and standard deviation values. 
// Credits:
// - DeepImageJ team:
// 		- Reference: DeepImageJ: A user-friendly environment to run deep learning models in ImageJ,
// 			     E. Gómez-de-Mariscal, C. García-López-de-Haro, W. Ouyang, L. Donati, E. Lundberg, M. Unser, A. Muñoz-Barrutia, D. Sage,
//             	             Nat Methods 18, 1192–1195 (2021). https://doi.org/10.1038/s41592-021-01262-9
// ----------------------------------------------------------------------------------------------

// clip the range of values to the [0,1] range
run("32-bit");
getStatistics(_, _, min, max, _, _);
run("Subtract...", "value=" + min);
diff = max - min + 1e-20
run("Divide...", "value=" + diff);
setMinAndMax(0, 1);

// mean normalization
paramMean = 0.23325787;
paramStd = 0.15511274;
run("Subtract...", "value="+paramMean);
run("Divide...", "value="+paramStd);

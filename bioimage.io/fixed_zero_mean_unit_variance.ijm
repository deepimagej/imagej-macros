// ----------------------------------------------------------------------------------------------
// This macro applies a Z-score normalization using specific mean and standard deviation values. 
// Credits:
// - DeepImageJ team:
// 		- Reference: 
//		"DeepImageJ: A user-friendly plugin to run deep learning models in ImageJ", 
// 		E. Gomez-de-Mariscal, C. Garcia-Lopez-de-Haro, et al., bioRxiv 2019.
// ----------------------------------------------------------------------------------------------

// Input parameters: set them according to the values in the model.yaml 
paramMean = 0.23325787;
paramStd = 0.15511274;

// convert the image into float
run("32-bit");
// mean normalization
run("Subtract...", "value="+paramMean);
run("Divide...", "value="+paramStd);

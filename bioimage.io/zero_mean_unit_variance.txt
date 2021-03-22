// ----------------------------------------------------------------------------------------------
// This macro applies a Z-score normalization using the mean and standard deviation values of the input image. Thus the image is normalize to have zero mean and unit standard deviation.
// Credits:
// - DeepImageJ team:
// 		- Reference: 
//		"DeepImageJ: A user-friendly plugin to run deep learning models in ImageJ", 
// 		E. Gomez-de-Mariscal, C. Garcia-Lopez-de-Haro, et al., bioRxiv 2019.
// ----------------------------------------------------------------------------------------------

// clip the range of values to the [0,1] range
run("32-bit");
getStatistics(_, mean, min, max, std,_);
print("Mean value:"+mean)
print("Standard deviation value:"+std)
// mean normalization
run("Subtract...", "value="+mean);
run("Divide...", "value="+std);

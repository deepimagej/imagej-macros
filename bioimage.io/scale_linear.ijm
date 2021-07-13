// ----------------------------------------------------------------------------------------------
// This macro scales the intensity of an image with a fixed multiplicative and additive factor.
// 	gain: multiplicative factor
// 	offset: additive factor
// 	axes: the subset of axes to scale jointly. For example xy to scale the two image axes for 2d data
//		jointly. The batch axis (b) is not valid here.
// Credits:
// - DeepImageJ team:
// 		- Reference:
//		"DeepImageJ: A user-friendly plugin to run deep learning models in ImageJ",
// 		E. Gomez-de-Mariscal, C. Garcia-Lopez-de-Haro, et al., bioRxiv 2019.
// ----------------------------------------------------------------------------------------------

gain = 1;
offset = 0;

// Convert the intensity values to float so we can operate
run("32-bit");
run("Multiply...", "value=" + gain);
run("Add...", "value=" + offset);


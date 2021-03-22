// ----------------------------------------------------------------------------------------------
// This macro calculates a binary mask given a certain threshold.
// Credits:
// - DeepImageJ team:
// - Reference: "DeepImageJ: A user-friendly plugin to run deep learning models in ImageJ,
// 	E. Gomez-de-Mariscal, C. Garcia-Lopez-de-Haro, et al., bioRxiv 2019.
// ----------------------------------------------------------------------------------------------


getStatistics(_, _, min, max, _, _);
// Threshold the output.
optimalThreshold = 0.5;
setThreshold(optimalThreshold, max);
setOption("BlackBackground", true);
run("Convert to Mask", "method=Default background=Dark black");
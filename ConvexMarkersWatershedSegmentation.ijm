// ----------------------------------------------------------------------------------------------
// This macro takes two images (a probability map of the segmentation and a probability map for 
// convex markers. Here called as "C4-resultImage" and "C2-resultImage" respectively. 
// It calculates the convex markers, binarizes the image and runs a marker controlled watershed. 
// MorpholibJ is needed.
// PARAMETERS depend on the dataset being employed to obtain the probability maps. 
// Credits:
// - This code was exported from the python code of UVA-NL submission to the CTC http://celltrackingchallenge.net/
// - DeepImageJ team:
// 		- Reference: DeepImageJ: A user-friendly environment to run deep learning models in ImageJ,
// 			     E. Gómez-de-Mariscal, C. García-López-de-Haro, W. Ouyang, L. Donati, E. Lundberg, M. Unser, A. Muñoz-Barrutia, D. Sage,
//             	             Nat Methods 18, 1192–1195 (2021). https://doi.org/10.1038/s41592-021-01262-9
// ----------------------------------------------------------------------------------------------

// Run these lines when using the output of Mu-Lux-CZ trained model. Otherwise, omit them
rename("resultImage");
run("Split Channels");
selectWindow("C1-resultImage");
close();
selectWindow("C3-resultImage");
close();

// PARAMETERS
// 'PhC-C2DL-PSC':
//erosion_size = 1;
MARKER_THRESHOLD=240;
C_MASK_THRESHOLD=156;
// CIRCULAR = True;
STEP = 3;
//BORDER = 12;

// Threshold the output of the network for markers
print("Marker extraction");
selectWindow("C2-resultImage");
run("Duplicate...", "title=img_threshold");
run("Multiply...", "value=255");
run("Brightness/Contrast...");
setMinAndMax(0, 255);
run("8-bit");
// specific parameter
setThreshold(MARKER_THRESHOLD, 255);
setOption("BlackBackground", true);
run("Convert to Mask");
run("Divide...", "value=255"); 

// Start the process to obtain convex markers
selectWindow("C2-resultImage");
rename("markers");
//run("Duplicate...", "title=markers");
run("Multiply...", "value=255");
run("Brightness/Contrast...");
setMinAndMax(0, 255);
run("8-bit");
run("Morphological Filters", "operation=Opening element=Disk radius=3");
selectWindow("markers");
run("Close");
selectWindow("markers-Opening");
rename("markers");
run("Duplicate...", "title=h_img");
run("16-bit");
// specific parameter
run("Add...", "value="+STEP); 

// Image reconstruction to obtain convex markers
max = 255;
iterations = 1;
print("Start reconstruction process");
do {
	selectWindow("markers");
	run("Morphological Filters", "operation=Dilation element=Disk radius=3");
	selectWindow("markers-Dilation");
	rename("rec1");
	imageCalculator("Min", "rec1","h_img");
	imageCalculator("Subtract create", "rec1","markers");
	max=getValue("Max");
	selectWindow("markers");
	close();
	selectWindow("rec1");
	rename("markers");
	print(iterations, max);
	selectWindow("Result of rec1");
	close();
	iterations = iterations + 1;
	} while (max>0 && iterations<=255);
selectWindow("markers");
// specific parameter
run("Subtract...", "value="+STEP); 
run("Brightness/Contrast...");
setMinAndMax(0, 255);
run("8-bit");
selectWindow("h_img");
// specific parameter
run("Subtract...", "value="+STEP); 
run("Brightness/Contrast...");
setMinAndMax(0, 255);
run("8-bit");
// obtain final convex markers
imageCalculator("Subtract", "h_img","markers");
imageCalculator("Multiply", "h_img","img_threshold");
setThreshold(1, 255);
setOption("BlackBackground", true);
run("Convert to Mask");
// close remaining windows
selectWindow("markers");
close();
selectWindow("img_threshold");
close();
selectWindow("h_img");
rename("markers");

// PROCESS BINARY SEGMENTATION
print("Instance segmentation");
selectWindow("C4-resultImage");
rename("cells");
run("Duplicate...", "title=cell_mask");
run("Multiply...", "value=255");
run("Brightness/Contrast...");
setMinAndMax(0, 255);
run("8-bit");


// Binarize the cell segmentation
// specific parameter
setThreshold(C_MASK_THRESHOLD, 255);
setOption("BlackBackground", true);
run("Convert to Mask");
imageCalculator("Max", "cell_mask","markers");

// Marker controlled watershed
selectWindow("cells");
run("Invert");
run("Marker-controlled Watershed", "input=cells marker=markers mask=cell_mask binary calculate use");
selectWindow("cells-watershed");
run("glasbey on dark");
run("Brightness/Contrast...");
resetMinAndMax();
selectWindow("B&C"); 
run("Close");

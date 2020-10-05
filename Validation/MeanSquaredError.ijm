//*******************************************************************
// Date: September-2020
// Credits: DeepImageJ
// URL: 
// 		https://deepimagej.github.io/deepimagej
//*******************************************************************
// This macro computes the mean squared error between the images in 
// a folder and the respective ground truth / image of reference.

// The images should be organized as follows:
// Path_to_images: name_1.tif, name_2.tif, ...
// Path_to_ground_truth: name_1.tif, name_2.tif, ...

// The image format can be any one compatible with Fiji&ImageJ. 
// The name of the images can be any but each image and its respective
// ground truth should have the same name.
//*******************************************************************
//setBatchMode(true);
run("Clear Results")

// Specify the directory with the images to process 
path_images = "D:/Documents/BiiG/DeepImageJ/test_validation/images/"
path_gt = "D:/Documents/BiiG/DeepImageJ/test_validation/ground truth/"

// Read the name of all the files in the image and ground truth directories.
list = getFileList(path_images);
print(list.length+" images to evaluate.");
list = getFileList(path_gt);
print(list.length+" ground truth images.");

// Create a directory in the images directory where the results will be stored
path_results = path_images+"evaluation_results/"
  if (!File.exists(path_results)){
  	File.makeDirectory(path_results);
  	if (!File.exists(path_results)){
  		exit("Unable to create a directory for the results");
  	}
  }

// Process each image with the trained model and save the results.
MSE = 0;
STD = 0;
M = 0;
m = 10000000;
for (i=0; i<list.length; i++) {
	// avoid any subfolder
	if (!endsWith(list[i], "/")){
		// store the name of the image to save the results
		image_name = split(list[i], ".");
		image_name = image_name[0];
		// open the image
		open(path_images + list[i]);  
		run("32-bit");
		rename("input");
		// open the ground truth
		open(path_gt + list[i]);  
		run("32-bit");
		rename("gt");
		// Calculate the Mean Squared Error between both images:
		imageCalculator("Subtract 32-bit", "input","gt");
		imageCalculator("Multiply 32-bit", "input","input");
		getRawStatistics(nPixels, mean, min, max, std);
		//run("Set Measurements...", "mean standard min redirect=None decimal=4");
		//run("Measure");
		setResult("File",i,image_name);
		setResult("MSE",i,mean);
		setResult("Std",i,std);
		setResult("Min",i,min);
		setResult("Max",i,max);
		if (M < max){
			M=max;
		}
		if (m> min){
			m=min;
		}
		MSE = MSE + mean;
		STD = i*(STD) + (mean - MSE/(i+1))*(mean - MSE/(i+1));
		STD = STD/(i+1);
        // save the error image
		selectImage("input");
		saveAs("Tiff", path_results+image_name+"_SquaredError.tif");
		close("*");
	}
}
// Set overall measures
setResult("File",list.length,"TOTAL");
setResult("MSE",list.length,MSE/list.length);
setResult("Std",list.length,STD);
setResult("Min",list.length,m);
setResult("Max",list.length,M);
// Store the results as a csv
saveAs("Results", path_results+"MSE.csv");
//close("Results");


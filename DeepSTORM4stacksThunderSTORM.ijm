//*******************************************************************
// Date: September-2020
// Credits: ZeroCostDL4Mic, DeepImageJ
// URL: 
// 		https://github.com/HenriquesLab/ZeroCostDL4Mic/wiki
// 		https://deepimagej.github.io/deepimagej
//*******************************************************************
//  Macro to run a DeepSTORM trained model recursively 
//  to each of the slices of one SMLM stack. 
//  DeepImageJ and ThunderSTORM plugin need to be installed
//*******************************************************************
// Choose a directory to store all the results
workingDir = getDirectory("Choose a directory to store your results");
tablesDir = workingDir + File.separator + "localization_csv_files";
File.makeDirectory(tablesDir);
modelName = "DeepSTORM - ZeroCostDL4Mic - Elias";
postprocessing_type = "postprocessing_LocalMaximaSMLM.ijm"; //"postprocessing_AveragedMaximaSMLM.ijm";
//  Change the name of the image
rename("input_stack");
//  Get the dimensions of the image, specially for the z-slices
getDimensions(w, h, channels, slices, frames);
print("Processing stack of "+ slices + " frames.");

for (i = 1; i < slices+1; i++) {
	
	// Select the volume
	selectImage("input_stack");
	
	// Extract one single z-slice
	run("Make Substack...", " slices="+i);
	
	// Rename the z-slice
	selectImage("Substack ("+i+")");	
	
	// Process each 2D frame with DeepSTORM (check patch and overlap values in the config file)
	// change the name of the post-processing for a regular local maxima finder
	run("DeepImageJ Run", "model=[" + modelName + "] preprocessing=preprocessing.ijm postprocessing=" + postprocessing_type + " patch=512 overlap=0 logging=normal");
	
	// Create a table with the coordinates of the local maxima and their value in the output
	selectWindow("Results");
	saveAs("Results", tablesDir + File.separator + "results_" + i + ".csv");
	close("Results");
	
	// Save the names of the z-slices to concatenate them into a new stack
	if (i==1) {
		// Create a table with the coordinates of the local maxima and their value in the output
		selectImage("normalizedConfidence");
		rename("totalSum");
		selectImage("filteredConfidence");
		rename("filteredSum");
	}
	else {
		imageCalculator("Add", "filteredSum","filteredConfidence");
		imageCalculator("Add", "totalSum","normalizedConfidence");
		// Close all unncessary images
		close("filteredConfidence");
		close("normalizedConfidence");
	}
	// Close all unncessary images
	close("Substack ("+i+")");
	close("upsampled_input");	
	print("Frame "+ i + " finished");
}
selectImage("totalSum");
saveAs("Tiff", workingDir + "totalSum.tif");
selectImage("filteredSum");
saveAs("Tiff", workingDir + "filteredSum.tif");
print("The results are stored in\n" + workingDir);

// Create a Thunderstorm table
//-----------------------------------------------------
thTable = getBoolean("Create ThunderSTORM table");
if (thTable == 1){
	close("*");	
	print("Creating a ThunderSTORM table from\n"+workingDir);
	// Display info about the files
  	list = getFileList(tablesDir);
  	run("Import results", "filepath=" + tablesDir + File.separator + "results_1.csv fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=1 append=true");
  	for (i=2; i<list.length+1; i++){
		run("Import results", "filepath=" + tablesDir + File.separator + "results_"+i+".csv fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=" + i +" append=true");
		// Export the table everytime we add info about a new frame
		run("Export results", "filepath=" + workingDir + File.separator + "ThunderSTORMtable.csv fileformat=[CSV (comma separated)] =false saveprotocol=true confidence=true x=true y=true local=false id=true frame=true");
	}
	print("Process finished");
}

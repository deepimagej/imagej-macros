//*******************************************************************
// Date: September-2020
// Credits: ZeroCostDL4Mic, DeepImageJ
// URL: 
// 		https://github.com/HenriquesLab/ZeroCostDL4Mic/wiki
// 		https://deepimagej.github.io/deepimagej
//*******************************************************************
//  Macro to run a DeepSTORM trained model recursively 
//  to each of the slices of one SMLM stack. 
//*******************************************************************

// PARAMS BY DEFAULT (same variables in the notebook)
thresh = 0.10;
pixelSize = 12.5; // in nm and after upsampling

// Choose a directory to store all the results
workingDir = getDirectory("Choose a directory to store your results");
modelName = "DeepSTORM - ZeroCostDL4Mic";

function createThuderSTORMtable(slice, imageName, thresh, pixelSize, row) { 
// This function creates a table with columns frame, x [nm], y [nm], P in a "brutal" manner.
// TODO: find some plugin that could do it.
	selectImage(imageName);
	// row=0;
	w=getWidth();
	h=getHeight();
	for(x=0;x<w;x++){
	     for(y=0;y<h;y++){
	         v=getPixel(x,y);
	         if (v<thresh){
				setPixel(x, y, 0.00);
	         }
	         else {
		        setResult("frame",row,slice);
		        setResult("x [nm]",row,x*pixelSize);
		        setResult("y [nm]",row,y*pixelSize);
		        setResult("confidence [a.u]",row,v);
		        row++;
	         }
		  }
	}
	updateResults();
	return row;
}
//  Get the name of the image
rename("input_stack");
//  Get the dimensions of the image, specially for the z-slices
getDimensions(w, h, channels, slices, frames);
print("Processing stack of "+ slices + " frames.");
// Remove setBacthMode to see the processing
// setBatchMode(true);
row = 0; // Initialize the row to update it in the big table
for (i = 1; i < slices+1; i++) {
	
	// Select the volume
	selectImage("input_stack");
	
	// Extract one single z-slice
	run("Make Substack...", " slices="+i);
	
	// Rename the z-slice
	selectImage("Substack ("+i+")");	
	
	// Process each 2D frame with DeepSTORM (check patch and overlap values in the config file)
	// change the name of the post-processing for a regular local maxima finder
	run("DeepImageJ Run", "model=[" + modelName + "] preprocessing=preprocessing.ijm postprocessing=postprocessing.ijm patch=512 overlap=0 logging=normal");
	
	// Create a table with the coordinates of the thresholded local maxima and their value in the output
	
	row = createThuderSTORMtable(i, "filteredConfidence", thresh, pixelSize, row);
	selectWindow("Results");
	saveAs("Results", workingDir + "results.csv");
	
	// Save the names of the z-slices to concatenate them into a new stack
	if (i==1) {
		// Create a table with the coordinates of the local maxima and their value in the output
		selectImage("normalizedConfidence");
		rename("totalSum");
		selectImage("filteredConfidence");
		rename("filteredSum");
	} else {
		imageCalculator("Add", "filteredSum","filteredConfidence");
		imageCalculator("Add", "totalSum","normalizedConfidence");
		// Close all unncessary images
		selectImage("filteredConfidence");
		close();
		selectImage("normalizedConfidence");
		close();
	}

	// Close all unncessary images
	selectImage("Substack ("+i+")");
	close();
	selectImage("upsampled_input");
	close();
	print("Frame "+ i + " finished");
}
selectImage("totalSum");
saveAs("Tiff", workingDir + "totalSum.tif");
selectImage("filteredSum");
saveAs("Tiff", workingDir + "filteredSum.tif");

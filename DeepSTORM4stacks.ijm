//*******************************************************************
// Date: September-2020
// Credits: DeepImageJ
// URL: 
// 		https://github.com/HenriquesLab/ZeroCostDL4Mic/wiki
// 		https://deepimagej.github.io/deepimagej
//*******************************************************************
//  Macro to run a DeepSTORM trained model recursively 
//  to each of the slices of one SMLM stack. 
//*******************************************************************
// PARAMS BY DEFAULT (same variables in the notebook)
thresh = 0.10 + 0.001;
neighborhood_size = 3;
pixelSize = 12; // in nm and after upsampling

//  Get the name of the image
rename("input_stack");

//  Get the dimensions of the image, specially for the z-slices
getDimensions(w, h, channels, slices, frames);



function createThuderSTORMtable(slice, imageName, thresh, pixelSize, row) { 
// This function creates a table with columns frame, x [nm], y [nm], P
	selectImage(imageName);
	// row=0;
	w=getWidth();
	h=getHeight();
	for(x=0;x<w;x++){
	     for(y=0;y<h;y++){
	         v=getPixel(x,y);
	         if (v>thresh){
	         setResult("frame",row,slice);
	         setResult("x [nm]",row,x*pixelSize);
	         setResult("y [nm]",row,y*pixelSize);
	         setResult("P(photon)",row,v);
	         row++;
	         }
	     }
	}
	return row;
	updateResults();
}

//  A z-slice is stracted and processed with DeepImageJ plugin.
// When all the z-slices are processed, they are concatenated to create the processed 3D stack.
row = 0;
for (i = 1; i < slices+1; i++) {
	
	// Select the volume
	selectImage("input_stack");
	
	// Extract one single z-slice
	run("Make Substack...", "channels=1-2 slices="+i);
	
	// Rename the z-slice
	selectImage("Substack ("+i+")");	
	
	// Process the z-slice with CARE Isotropic Reconstruction
	run("DeepImageJ Run", "model=[DeepSTORM - ZeroCostDL4Mic] preprocessing=preprocessing.ijm postprocessing=postprocessing.ijm patch=512 overlap=5 logging=normal");
	rename("output-"+i);

	// Create a table with the coordinates of the local maxima and their value in the output
	row = createThuderSTORMtable(i, "output-"+i, thresh, pixelSize, row);
	saveAs("Results", "/media/esgomezm/sharedisk/Documents/BiiG/DeepImageJ/DeepSTORM/results.csv");
	// Save the names of the z-slices to concatenate them into a new stack
	if (i==1) {
		// Create a table with the coordinates of the local maxima and their value in the output
		selectImage("output-"+i);
		rename("totalSum");
	} else {
		imageCalculator("Add", "totalSum","output-"+i);
		selectImage("output-"+i);
		close();
	}
	
	// Close the input z-slice
	selectImage("Substack ("+i+")");
	close();
	selectImage("upsampled_input");
	close();
	
	}


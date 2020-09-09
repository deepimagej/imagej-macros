// ----------------------------------------------------------------------------------------------
// This macro finds the local maxima of an image that is lower than a certain threshold. Results 
// are provided as a 2D image and a table.
// This code is a replication the post-processing at Deep-STORM_2D_ZeroCostDL4Mic notebook.
// Credits:
// - ZeroCostDL4Mic: Lucas von Chamier, et al., bioRxiv 2020.
// - DeepImageJ: E. Gomez-de-Mariscal, C. Garcia-Lopez-de-Haro, et al., bioRxiv 2019.
// ----------------------------------------------------------------------------------------------

// PARAMS BY DEFAULT (same variables in the notebook)
// If condition acts as >= rather than >
thresh = 0.10;
L2_weighting_factor = 170.21;
neighborhood_size = 3;
pixelSize = 12; // in nm and after upsampling
//-------------------------------------------------------

rename("normalizedConfidence");
// Remove negative values from the image
run("Min...", "value=0");
//correct the weighting factor
run("Divide...", "value=" + L2_weighting_factor);

// Local maxima finder
//-------------------------------------------------------
run("Duplicate...", "title=maxPooling");
run("Duplicate...", "title=filteredConfidence");
// MaxPoolig of radius 3 with stride of 1x1
// (kernel is a circle)
selectWindow("maxPooling");
run("Maximum...", "radius="+neighborhood_size);
// True maximum
imageCalculator("Subtract","maxPooling", "normalizedConfidence");
run("Manual Threshold...", "min=0 max=0");
setOption("BlackBackground", true);
run("Convert to Mask");
// Make binary
run("32-bit");
run("Divide...", "value=255");
// Recover confidence values
imageCalculator("Multiply", "filteredConfidence","maxPooling");
// run("Min...", "value=" + thresh); // remove everything below thresh
selectWindow("maxPooling");
close();

// Create a csv file with the localizations and confidence values
// (brutal code with loops).
//-------------------------------------------------------
// The loop filters low confidence values as well.
selectWindow("filteredConfidence");
// One chance of finding a maxima localization just with the threshold
// run("Find Maxima...", "prominence=0.10 strict output=List");

row=0;
w=getWidth();
h=getHeight();
for(x=0;x<w;x++){
     for(y=0;y<h;y++){
         v=getPixel(x,y);
         if (v<thresh){
		setPixel(x, y, 0.00);
         }
         else {
	        setResult("frame",row,1);
	        setResult("x [nm]",row,x*pixelSize);
	        setResult("y [nm]",row,y*pixelSize);
	        setResult("confidence [a.u]",row,v);
	        row++;
         }
     }
}
updateResults();
// To store the table just run:
// saveAs("Results", "/media/DeepSTORM/results_frame001.csv");

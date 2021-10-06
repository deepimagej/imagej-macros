// ----------------------------------------------------------------------------------------------
// This macro finds the local maxima of an image that is lower than a certain threshold and 
// estimtes the center of gravity for each maxima. Results are provided as a 2D image and a table.
// This code is a replication the post-processing at Deep-STORM_2D_ZeroCostDL4Mic notebook.
// Credits:
// - ZeroCostDL4Mic: Lucas von Chamier, et al., bioRxiv 2020.
// - DeepImageJ: E., García-López-de-Haro, C., Ouyang, W. et al., Nat Methods 18, 1192–1195 (2021).
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
close("maxPooling");

// Create a csv file with the localizations and confidence values
// (brutal code with loops).
//-------------------------------------------------------
// The loop filters low confidence values as well.
selectWindow("filteredConfidence");
// One chance of obtaining maxima localization with the threshold
// run("Find Maxima...", "prominence=0.10 strict output=List");

// Averaged local maxima calculator
selectImage("normalizedConfidence");
run("Duplicate...", "title=x");
run("Duplicate...", "title=y");
run("Duplicate...", "title=sum");

selectImage("x");
run("Convolve...", "text1=[-1 0 1\n-1 0 1\n-1 0 1]");

selectImage("y");
run("Convolve...", "text1=[-1 -1 -1\n0 0 0\n1 1 1]");

selectImage("sum");
run("Convolve...", "text1=[1 1 1\n1 1 1\n1 1 1]");
run("Concatenate...", "  title=maximaFinder image1=filteredConfidence image2=sum image3=x image4=y image5=[-- None --]");
selectImage("maximaFinder");
row=0;
thresh = 0.1;
pixelSize = 12.5;
w=getWidth();
h=getHeight();
for(x=0;x<w;x++){
     for(y=0;y<h;y++){
       	setSlice(1);
        v=getPixel(x,y);
         if (v<thresh){
		setPixel(x, y, 0.00);
		setSlice(2);
		setPixel(x,y,0.00);
         }
         else {
         	setSlice(2);
         	sumV = getPixel(x,y);
         	setSlice(3);
         	x_local = getPixel(x,y);
         	x_local = x_local/sumV;
         	setSlice(4);
         	y_local = getPixel(x,y);
         	y_local = y_local/sumV;         	
	        setResult("frame",row,1);
	        setResult("x [nm]",row,(x+x_local)*pixelSize);
	        setResult("y [nm]",row,(y+y_local)*pixelSize);
	        setResult("confidence [a.u.]",row,sumV);
	        row++;
         }
     }
}
updateResults();
// To store the table just run:
// saveAs("Results", "/media/DeepSTORM/results_frame001.csv");
// recover the values displayed in the results table.
selectImage("maximaFinder");
setSlice(1);
run("Delete Slice");
setSlice(2);
run("Delete Slice");
setSlice(2);
run("Delete Slice");
rename("filteredConfidence");

// ----------------------------------------------------------------------------------------------
// This macro finds the local maxima of an image that is lower than a certain threshold. It first
// computes a maxPooling of the image with a kernel of size 3x3. Then it filters out all the
// maximum points apearing also in the initial image. Finally, it filters out all the values below
// a certain threshold. 
// Credits:
// - DeepImageJ team:
// 		- Reference: "DeepImageJ: A user-friendly plugin to run deep learning models in ImageJ, 
// 						E. Gomez-de-Mariscal, C. Garcia-Lopez-de-Haro, et al., bioRxiv 2019.
// ----------------------------------------------------------------------------------------------

// PARAMS BY DEFAULT (same variables in the notebook)
// If condition acts as >= rather than >
thresh = 0.10 + 0.0001;
neighborhood_size = 3;

//-------------------------------------------------------
rename("rawOutput");
// Remove negative values from the image
run("Min...", "value=0");
// Local maxima finder
//-------------------------------------------------------
run("Duplicate...", "title=maxPooling");
run("Duplicate...", "title=filteredProbability");
// MaxPoolig of radius 3 with stride of 1x1
// (kernel is a circle)
selectWindow("maxPooling");
run("Maximum...", "radius="+neighborhood_size);
// True maximum
imageCalculator("Subtract","maxPooling", "rawOutput");
run("Manual Threshold...", "min=0 max=0");
setOption("BlackBackground", true);
run("Convert to Mask");
// Make binary
run("32-bit");
run("Divide...", "value=255");
// Filter out noise or low probabilities
selectWindow("filteredProbability");
run("Min...", "value=" + thresh);
// True maximum larger than a threshold
imageCalculator("Multiply", "filteredProbability","maxPooling");

selectWindow("maxPooling");
close();
selectWindow("rawOutput");
close();


// Add the following lines to the macro that processes the entire stack
// pixelSize = 12; // in nm and after upsampling
//selectWindow("filteredProbability");
// One chance of finding a maxima just with the threshold
// run("Find Maxima...", "prominence=0.10 strict output=List");
// Create a thunderstorm table (brutal code with loops)
//row=0;
//w=getWidth();
//h=getHeight();
//for(x=0;x<w;x++){
//     for(y=0;y<h;y++){
//         v=getPixel(x,y);
//         if (v>thresh){
//         setResult("x [nm]",row,x*pixelSize);
//         setResult("y [nm]",row,y*pixelSize);
//         setResult("P(photon)",row,v);
//         row++;
//         }
//     }
//}
//updateResults();
// saveAs("Results", "/media/DeepSTORM/results_frame001.csv");

//*******************************************************************
// Date: July-2021
// Credits: StarDist, DeepImageJ
// URL: 
// 		https://github.com/stardist/stardist
// 		https://deepimagej.github.io/deepimagej
// Please cite the respective contributions when using this code.
//*******************************************************************
//  Macro to run a the StarDist postprocessing on 2D images. 
//  StarDist and deepImageJ plugins need to be installed.
//  The macro assumes that the image to process is a stack in which 
//  the first channel corresponds to the object detection probability 
//  map and the remaining channels are the oriented distances from the
//  object border to its center.
//*******************************************************************

// Get the name of the image to call it
name=getTitle();

// Upsample the image:
grid = 2;
getDimensions(width, height, channels, slices, frames);
run("Scale...", "x=" + grid + " y=" + grid + " z=1.0 width=" + grid*width + " height=" + grid*height + " depth=" + channels + " interpolation=Bicubic average process create title=upsampled");
selectWindow(name);
close();
selectWindow("upsampled");
rename(name);

// Isolate the detection probability scores
run("Make Substack...", "channels=1");
rename("scores");

// Isolate the oriented distances
run("Fire");
selectWindow(name);
run("Delete Slice", "delete=channel");
selectWindow(name);
rename("distances");
run("royal");

// Run StarDist plugin
probThresh = 0.7
nmsThresh = 0.2
run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2DNMS], args=['prob':'scores', 'dist':'distances', 'probThresh':'" + probThresh + "', 'nmsThresh':'" + nmsThresh + "', 'outputType':'Both', 'excludeBoundary':'2', 'roiPosition':'Stack', 'verbose':'false'], process=[false]");



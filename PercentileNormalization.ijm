// ----------------------------------------------------------------------------------------------
// This macro calculates the 1th and 99.8th percentiles of an image histogram 
// and normalizes it to the [0,1] range.
// Credits:
// - Base code from BenTupper http://imagej.1557.x6.nabble.com/Percentile-value-td3690983.html
// - DeepImageJ team:
// 		- Reference: "DeepImageJ: A user-friendly plugin to run deep learning models in ImageJ, 
// 						E. Gomez-de-Mariscal, C. Garcia-Lopez-de-Haro, et al., bioRxiv 2019.
// ----------------------------------------------------------------------------------------------

function percentile_normalization(){
	nBins = 256; // the larger the more accurate
	getHistogram(values, counts, nBins);
	
	//create a cumulative histogram
	cumHist = newArray(nBins);
	cumHist[0] = values[0];
	for (i = 1; i < nBins; i++){ cumHist[i] = counts[i] + cumHist[i-1]; }
	
	//normalize the cumulative histogram
	normCumHist = newArray(nBins);
	for (i = 0; i < nBins; i++){  normCumHist[i] = cumHist[i]/
	cumHist[nBins-1]; }
		
	// find the 1th percentile (= 0.01)
	target = 0.01;
	i = 0;
	do {
	        i = i + 1;
	        // print("i=" + i + "  value=" + values[i] +  "  count=" + counts[i] + "cumHist= " + cumHist[i] + "  normCumHist= " + normCumHist[i] );
	} while (normCumHist[i] < target)
	mi = values[i];
	// print("1th percentile has value " + mi);
	
	// find the 99.85th percentile (= 0.998)
	target = 0.998;
	i = 0;
	do {
	        i = i + 1;
	        // print("i=" + i + "  value=" + values[i] +  "  count=" + counts[i] + "cumHist= " + cumHist[i] + "  normCumHist= " + normCumHist[i] );
	} while (normCumHist[i] < target)
	ma = values[i];
	// print("99.8th percentile has value " + ma);
	
	diff = ma-mi+1e-20; // add epsilon to avoid 0-divisions
	run("32-bit");
	run("Subtract...", "value="+mi);
	run("Divide...", "value="+diff);
	
}
percentile_normalization();

//END MACRO

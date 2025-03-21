This folder contains several functions to be used for unmixing hyperspectral data. The functions are:

CONTENTS:
- the elmm foler: containing an implementation of the Extended Linear Mixing Model (ELMM) by Drumetz et al. (2016):
- the synthesis folder: functions to generate synthetic abundance maps according to Gaussian Random Fields (GRF), which can be foun at https://www.ehu.eus/ccwintco/index.php/Hyperspectral_Imagery_Synthesis_tools_for_MATLAB
- abundance_error.m: Function to calculate the abundance error of a hyperspectral image (RMSE)
- calculate_abundance.m: Function that generates a structured abundance sequence uniformly covering the simplex
- E.mat: A file containing the endmembers of a hyperspectral image.
- FCLSU.m: Function to perform Fully Constrained Least Squares Unmixing (FCLSU)
- generate_structured_data.m: Function that generates a structured abundance sequence uniformly covering the simplex
- generateSyntheticImage.m: Function to generate a synthetic image with a given number of endmembers and a given number of pixels with GRF abundance maps
- getScalingsSampleGaussianField.m: Function to generate scaling factors for a synthetic image using Gaussian Random Fields
- image_error.m: Function to calculate the reconstruction error of a hyperspectral image (RMSE or SAD)
- model_errors.m: Function to calculate the abundance and (possibly) scaling factor errors of a hyperspectral image
- plot_abundance_map.m: Function to plot the abundance maps of a hyperspectral image. This function is made to work inside a subplot with multiple abundance map estimations.
- plot_reconstruction_error.m: Function to plot the reconstruction error of a hyperspectral image pixel-wise (RMSE or SAD)
- plot_scaling_factors.m: Function to plot the scaling factors of a hyperspectral image. The plot generates two subplots: a histogram of the scaling factors and a boxplot of the scaling factors.
- README.txt: This file
- reconstruct.m: Function to reconstruct a hyperspectral image from its endmembers, scaling factors, and abundance maps. The model type is deduced from the size of the scaling factors.
- run_ELMM.m: Script to run the Extended Linear Mixing Model (ELMM) on a synthetic image, using the code by Drumetz et al. (2016)
- scaling_error.m: Function to calculate the scaling factor error of a hyperspectral image (RMSE or SAD)
- SCLSU.m: Function to perform Scaled Constrained Least Squares Unmixing (SCLSU)

DEPENDENCIES:
- The functions in this folder depend on the MATLAB Image Processing Toolbox and the MALTAB hyperspectral imaging library
- The function generateSyntheticImage.m depends on the hyperspectral data retrieval and analys tool developed by the Grupo Inteligencia Computacional, Universidad del País Vasco / Euskal Herriko Unibertsitatea (UPV/EHU)
and which can be found at http://www.ehu.es/ccwintco
- The function run_ELMM.m depends on the code by Drumetz et al. (2016), based on the paper published in the same year:
Drumetz, L., Veganzones, M.-A., Henrot, S., Phlypo, R., Chanussot, J., & Jutten, C. (2016). Blind Hyperspectral Unmixing Using an Extended Linear Mixing Model to Address Spectral Variability. IEEE Transactions on Image Processing, 25(8), 3890–3905. https://doi.org/10.1109/TIP.2016.2579259
The code can be found at
https://openremotesensing.net/knowledgebase/spectral-variability-and-extended-linear-mixing-model/
- Plotting the scaling factors depends on the MATLAB Statistics and Machine Learning Toolbox
- The functions FCLSU, CLSU and ELMM can benefit from the MATLAB Parallel Computing Toolbox

NAMING CONVENTIONS:
- The number of pixels is denoted by 'n', the number of endmembers by 'k', and the number of bands by 'p'
- Image dimensions are denoted by 'width' and 'height'
- The abundance maps are denoted by 'A', an have dimensions 'k' x 'n'
- The endmembers are denoted by 'E', and have dimensions 'p' x 'k'
- The image matrix is denoted by 'X', and has dimensions 'n' x 'p'. When we deviate from this, it is mentioned in the function documentation
- A reshaped image matrix is denoted with the suffix '_r', and has dimensions 'width' x 'height' x 'p'
- The scaling factors are denoted by 'S', and have dimensions which depend on the model type
- To distinguish between real and reconstructed/measured values, the latter have a suffix '_hat', '_cap', or a suffix related to the model type

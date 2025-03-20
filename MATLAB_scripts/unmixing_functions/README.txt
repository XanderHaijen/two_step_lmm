This folder contains several functions to be used for unmixing hyperspectral data. The functions are:

CONTENTS:
- abundance_error.m: Function to calculate the abundance error of a hyperspectral image (RMSE)
- angle_two_step_LMM.m: Function that defines the cost function used in ip_2LMM_angle.m
- calculate_abundance.m: Function that generates a structured abundance sequence uniformly covering the simplex
- E.mat: A file containing the endmembers of a hyperspectral image.
- FCLSU.m: Function to perform Fully Constrained Least Squares Unmixing (FCLSU)
- generate_stand_image.m, which is a wrapper function for generateSyntheticImage.m using some standard GRF parameters
- generateSyntheticImage.m: Function to generate a synthetic image with a given number of endmembers and a given number of pixels with GRF abundance maps (GRF = Gaussian Random Field)
- getScalingsSampleGaussianField.m: Function to generate scaling factors for a synthetic image using Gaussian Random Fields
- image_error.m: Function to calculate the reconstruction error of a hyperspectral image
- ip_2LMM_angle.m: Function to solve the 2-step Linear Mixing Model (2LMM) using an Interior Point method with SAD minimization
- ip_2LMM_norm.m: Function to solve the 2-step Linear Mixing Model (2LMM) using an Interior Point method with the norm-adjusted version of the objective function
- ip_2LMM.m: Function to solve the 2-step Linear Mixing Model (2LMM) using an Interior Point method with the two-scaling factor version of the objective function
- model_errors.m: Function to calculate the abundance and (possibly) scaling factor errors of a hyperspectral image
- multimodalGaussian.m: Function to generate a multimodal Gaussian distribution
- norm_two_step_LMM.m: Function that defines the vectorized cost function used in ip_2LMM_norm.m
- plot_abundance_map.m: Function to plot the abundance maps of a hyperspectral image. This function is made to work inside a subplot with multiple abundance map estimations.
- plot_reconstruction_error.m: Function to plot the reconstruction error of a hyperspectral image pixel-wise
- plot_scaling_factors.m: Function to plot the scaling factors of a hyperspectral image. The plot generates two subplots: a histogram of the scaling factors and a boxplot of the scaling factors.
- README.txt: This file
- reconstruct.m: Function to reconstruct a hyperspectral image from its endmembers, scaling factors, and abundance maps. The model type is deduced from the size of the scaling factors.
- run_ELMM.m: Script to run the Extended Linear Mixing Model (ELMM) on a synthetic image, based on the code by Drumetz et al. (2016)
- scaling_error.m: Function to calculate the scaling factor error of a hyperspectral image (RMSE or SAD)
- SCLSU.m: Function to perform Scaled Constrained Least Squares Unmixing (SCLSU)
- two_step_LMM.m: Function that defines the vectorized cost function used in ip_2LMM.m

DEPENDENCIES:
- The functions in this folder depend on the MATLAB Image Processing Toolbox and the MALTAB hyperspectral imaging library
- The function generateSyntheticImage.m depends on the hyperspectral data retrieval and analys tool developed by the Grupo Inteligencia Computacional, Universidad del País Vasco / Euskal Herriko Unibertsitatea (UPV/EHU)
and which can be found at http://www.ehu.es/ccwintco
- The function run_ELMM.m depends on the code by Drumetz et al. (2016), based on the paper published in the same year, which can be found at
https://openremotesensing.net/knowledgebase/spectral-variability-and-extended-linear-mixing-model/
- Optimization scripts depend on MATLAB's Optimization Toolbox and Global Optimization Toolbox
- Plotting the scaling factors depends on the MATLAB Statistics and Machine Learning Toolbox

NAMING CONVENTIONS:
- The number of pixels is denoted by 'n', the number of endmembers by 'k', and the number of bands by 'p'
- Image dimensions are denoted by 'width' and 'height'
- The abundance maps are denoted by 'A', an have dimensions 'k' x 'n'
- The endmembers are denoted by 'E', and have dimensions 'p' x 'k'
- The image matrix is denoted by 'X', and has dimensions 'n' x 'p'. When we deviate from this, it is mentioned in the function documentation
- A reshaped image matrix is denoted with the suffix '_r', and has dimensions 'width' x 'height' x 'p'
- The scaling factors are denoted by 'S', and have dimensions which depend on the model type
- To distinguish between real and reconsutructed/measured values, the latter have a suffix '_hat', '_cap', or a suffix related to the model type

# Two-Step Linear Mixing Model (LMM)

This project implements a two-step Linear Mixing Model (2LMM) for hyperspectral unmixing. The two-step LMM is designed to handle spectral variability by incorporating pixel- and endmember-specific scaling factors. The project includes tools for generating synthetic data, applying the two-step LMM, and evaluating the results.

## Re-use
This project is licensed under the CC-BY-SA-4.0 License. See the LICENSE file for details.

If you find this project useful in your own work, please cite this repository and/or the paper
*Haijen, X., Koirala, B., Tao, X., & Scheunders, P. (2025). A Two-step Linear Mixing Model for Unmixing under Hyperspectral Variability. To appear in the 45th International Geoscience and Remote Sensing Symposium (IGARSS), Brisbane.*

## Requirements

1. a MATLAB license and the MATLAB software. See https://nl.mathworks.com/products/matlab.html. Recommended MATLAB extensions are the *Image Processing Toolbox*, *Parallel Computing Toolbox*, *Image Processing Toolbox*, and the *Hyperspectral Imaging Library for Image Processing Toolbox*.
2. a recent version of Julia. See https://julialang.org/downloads/
3. The Julia packages ```LinearAlgebra```, ```JuMP```, ```Ipopt```, ```MAT``` and ```MathOptInterface```

## Structure
This project contains the following folders and subfolder
1. Julia_scripts: a folder containing two experiment files, and ```ip_unmixing.jl```, a file with Julia functions for hyperspectral unmixing.
2. MATLAB_scripts: a folder with several subfolders
    - **DLR_HySU**: containing the data for the DLR semi-real experiment. This data was obtained by the team of D. Cerra at the German Aerospace Centre. For more information, refer to *Cerra, D., Pato, M., Alonso, K., Köhler, C., Schneider, M., de los Reyes, R., Carmona, E., Richter, R., Kurz, F., Reinartz, P., & Müller, R. (2021). DLR HySU—A Benchmark Dataset for Spectral Unmixing. Remote Sensing, 13(13), 2559. https://doi.org/10.3390/rs13132559*
    - **experiments**: containing three experiments, one (ELMM_comparison) on synthetic data, one (dlr_semi_real) on hybrid data, and one (houston) on real data. Refer to the individual files for more details.
    - **Houston_data**: containing the data for the Houston experiment. Data from *Debes, C., Merentitis, A., Heremans, R., Hahn, J., Frangiadakis, N., van Kasteren, T., Liao, W., Bellens, R., Pižurica, A., Gautama, S., Philips, W., Prasad, S., Du, Q., & Pacifici, F. (2014). Hyperspectral and LiDAR Data Fusion: Outcome of the 2013 GRSS Data Fusion Contest. IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing, 7(6), 2405–2418. https://doi.org/10.1109/JSTARS.2014.2305441*
    - **unmixing_functions**: containing the MATLAB functions and auxiliary routines used in the experiments. Refer to this folder's README file for more information
3. LICENSE.txt, containing the license
4. README.md, this file

## Contact

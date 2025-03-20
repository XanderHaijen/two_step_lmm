The DLR HySU (HyperSpectral Unmixing) dataset aims at providing a reference benchmark to assess the performance of spectral unmixing algorithms using real data with associated reference data. The dataset is free to use and share given that appropriate credits are given (see citation below).

The directories are organized as follows:

- 3K_RGB contains the high resolution georeferenced RGB image in TIFF format

- HySpex contains the hyperspectral dataset. All files are TIFF with associated ENVI header file containing wavelengths and other metadata in ASCII format. You can load the data directly in ENVI. All subdirectories also contain a png true color combination, resized and oversampled for smaller images:

	- "full" contains the full subset containing the targets of interest
	- "large" contains the subset including [3 m x 3 m] targets
	- "small" contains the subset covering [0.5 m x 0.5 m] and [0.25 m x 0.25 m] targets
	- "targets" contains the subset with all targets, plus:
	 	- all ROIs with the locations of the targets grouped by size
	 	- all ROIs with the locations of the targets grouped by material
		- a binary mask in png format covering areas of the image which contain different materials from the 6 contained in the spectral libraries

- spectral_libraries contains the spectra collected from the image and from in situ measurements:

	- HySpex_data contains:
		- DLR_HySU_HS_library.lib is the HySpex library in ENVI format, with associated .hdr file
		- DLR_HySU_HS_library_ASCII.txt is the HySpex library in ASCII file

	- SVC_data contains the spectra measured in situ:
		- DLR_HySU_SVC.h5 is the original (not interpolated) Level 2 product as hdf5
		- DLR_HySU_SVC.sli is the ENVI spectral library with the interpolated and averaged spectra
		- DLR_HySU_SVC_ASCII.txt is the same library as above as an ASCII file

A Shortwave Infrared (SWIR) dataset was acquired on the same area during the same overflight with the additional HySpex SWIR sensor, and is available upon request. Please be aware that its spatial resolution is halved with respect to the HySpex VNIR dataset provided here, and the two HySpex sensors must be coregistered before obtaining spectral information in the full 0.4-2.5 micrometers spectral range.

If you use this dataset, please cite the paper:

Cerra, D.; Pato, M.; Alonso, K.; Köhler, C.; Schneider, M.; de los Reyes, R.; Carmona, E.; Richter, R.; Kurz, F.; Reinartz, P.; Müller, R. DLR HySU—A Benchmark Dataset for Spectral Unmixing. Remote Sens. 2021, 13, 2559. https://doi.org/10.3390/rs13132559 

available at:
https://www.mdpi.com/2072-4292/13/13/2559

Further information are available on DLR website:
https://www.dlr.de/eoc/en/desktopdefault.aspx/tabid-12760/22294_read-73262


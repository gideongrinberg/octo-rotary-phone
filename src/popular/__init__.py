import unpopular
import numpy as np
from astropy.wcs import WCS

class CutoutData(unpopular.CutoutData):
    def __init__(self, tpf, remove_bad=True):
        self.time = tpf[1].data["TIME"]
        self.fluxes = tpf[1].data["FLUX"]
        self.flux_errors = tpf[1].data["FLUX_ERR"]
        self.quality = tpf[1].data["QUALITY"]
        self.wcs_info = WCS(tpf[2].header)

        self.flagged_times = self.time[self.quality > 0]

        if remove_bad:
            bool_good = self.quality == 0
            self.time = self.time[bool_good]
            self.fluxes = self.fluxes[bool_good]
            self.flux_errors = self.flux_errors[bool_good]

        self.flux_medians = np.nanmedian(self.fluxes, axis=0)
        self.cutout_sidelength_x = self.fluxes[0].shape[0]
        self.cutout_sidelength_y = self.fluxes[0].shape[1]
        
        self.flattened_flux_medians = self.flux_medians.reshape(
            self.cutout_sidelength_x * self.cutout_sidelength_y
        )

        self.normalized_fluxes = (self.fluxes / self.flux_medians) - 1
        self.flattened_normalized_fluxes = self.normalized_fluxes.reshape(
            self.time.shape[0], 
            self.cutout_sidelength_x * self.cutout_sidelength_y
        )

        self.normalized_flux_errors = self.flux_errors / self.flux_medians

class Source(unpopular.Source):
    def __init__(self, tpf, remove_bad=True):
        self.cutout_data = CutoutData(tpf, remove_bad=True)
        
        self.time = self.cutout_data.time
        self.aperture = None
        self.models = None
        self.fluxes = None
        self.flux_errs = None
        self.predictions = None
        self.detrended_lcs = None
        self.split_times = None
        self.split_predictions = None
        self.split_fluxes = None
        self.split_detrended_lcs = None

import os
import json
import popular
import unpopular
import numpy as np
import polars as pl
import lightkurve as lk
from scipy.signal import find_peaks
from astrocut import CutoutFactory
from astropy.coordinates import SkyCoord
from google.cloud import storage

def _count_harmonics(
    lc: lk.LightCurve, height: float = 0.15
) -> list[tuple[float, float]]:
    """Find the harmonics in the L-S periodogram of a given lightcurve.

    Args:
        lc (lk.LightCurve)
        height (float, optional): The minimum height of a peak as a fraction of the main harmonic. Defaults to 0.15.

    Returns:
        list[tuple[float, float]]: A list containing each harmonic as a tuple of period and power.
    """

    pg = lc.to_periodogram()
    period = pg.period_at_max_power

    if period.value >= 2:
        return []

    expected_harmonics = []
    for i in range(1, 9):
        expected_harmonics.append(period.value / i)

    peaks, properties = find_peaks(
        pg.power, distance=120, height=pg.max_power.value * height
    )

    peak_periods = [pg.period[idx].value for idx in peaks]

    found_harmonics = []
    for i, period in enumerate(peak_periods):
        if i >= len(expected_harmonics):
            break
        in_range = 0.9 * expected_harmonics[i] <= period <= 1.1 * expected_harmonics[i]
        if in_range:
            found_harmonics.append((period, properties["peak_heights"][i]))

    return found_harmonics

def is_complex(lc: lk.LightCurve) -> bool:
    """Check if a given lightcurve is complex by counting the number of harmonics."""
    return len(_count_harmonics(lc)) >= 3

def get_tpf(coords, sector, camera, ccd):
    """
    Generates a target pixel file (HDUList) for a given target.
    """
    # Note: This may need to be updated to use GCS instead of S3
    cube_file = f"gs://tess-public-data/tess-s{str(sector).zfill(4)}-{camera}-{ccd}-cube.fits"
    return CutoutFactory().cube_cut(cube_file, coords, cutout_size=50, memory_only=True)

def make_lightcurve(tpf):
    """
    Detrends a target pixel file and returns a lightkurve LightCurve object.
    """    
    s = popular.Source(tpf, remove_bad=True)
    s.set_aperture(rowlims=[25, 26], collims=[25, 26])
    s.add_cpm_model(exclusion_size=5, n=64, predictor_method="similar_brightness")
    s.set_regs([0.1])
    s.holdout_fit_predict(k=100)
    apt_detrended_flux = s.get_aperture_lc(data_type="cpm_subtracted_flux")
    
    return lk.TessLightCurve(time=s.time, flux=apt_detrended_flux)

def process_target(target):
    """
    Processes a target by making a lightcurve and checking it for complexity. 

    Args:
        target (dict): A dictionary with the TIC, RA, dec, sector, camera and ccd of the target.

    Returns:
        tuple[int, int, bool]: A tuple of the TIC, sector, and its complexity
    """
    tic, ra, dec, sector, camera, ccd = target.values()
    coords = SkyCoord(ra, dec, unit="deg", frame="icrs")

    tpf = get_tpf(coords, sector, camera, ccd)
    lc = make_lightcurve(tpf)
    return (tic, sector, is_complex(lc))

def tess_pipeline(request):
    """
    Cloud Function entry point for processing a target.
    
    Args:
        request (flask.Request): The request object.
        
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using make_response.
    """
    # Parse request data
    request_json = request.get_json(silent=True)
    
    if not request_json:
        return {"error": "No JSON received"}, 400
        
    target = request_json
    
    try:
        tic, sector, result = process_target(target)
        
        # Store result in Google Cloud Storage
        bucket_name = os.environ.get("RESULTS_BUCKET", "tess-pipeline-results")
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(f"{tic}_{sector}.json")
        
        blob.upload_from_string(
            json.dumps({
                "tic": tic,
                "sector": sector,
                "result": result
            }),
            content_type="application/json"
        )
        
        return {
            "tic": tic,
            "sector": sector,
            "result": result
        }
    except Exception as e:
        print(f"Error processing target: {str(e)}")
        return {"error": str(e)}, 500
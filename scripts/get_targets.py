import pandas as pd
from astropy.coordinates import SkyCoord
from tesswcs.locate import get_pixel_locations

df = pd.read_csv("./data/Targets_ggrinberg35.csv")
df = df[["ID", "ra", "dec"]]

coords = SkyCoord(df["ra"], df["dec"], unit="deg", frame="icrs")
obs = get_pixel_locations(coords)

obs_df = df.merge(obs.to_pandas(), left_index=True, right_on="Target Index")
obs_df = obs_df.rename(lambda c: c.lower() if c != "ID" else c, axis=1)
obs_df = obs_df[["ID", "ra", "dec", "sector", "camera", "ccd"]][obs_df["sector"] < 85]

obs_df.to_csv("./data/targets.csv", index=False)
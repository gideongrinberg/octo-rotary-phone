#! /usr/bin/env bash

curl -X POST https://process-tess-target-127178162795.us-east4.run.app \
-H "Authorization: bearer $(gcloud auth print-identity-token)" \
-H "Content-Type: application/json" \
-d '{
   "ID": 33398702,
   "ra": 344.420449437894,
   "dec": -8.06747255937119,
   "sector": 42,
   "camera": 1,
   "ccd": 1
}'
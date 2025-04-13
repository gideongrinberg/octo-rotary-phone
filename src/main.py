from pipeline import *

def handle_request(request):
    request_json = request.get_json(silent=True)
    
    if not request_json:
        return {"error": "No JSON received"}, 400
        
    target = request_json
    
    try:
        tic, sector, result = process_target(target)
        
        # Store result in Google Cloud Storage
        bucket_name = "tess-pipeline-results"
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
        
        return 200
    except Exception as e:
        print(f"Error processing target: {str(e)}")
        return {"error": str(e)}, 500
import requests
from models.models import (
    MalwareAnalysisResponse,
    MalwareLookupPayload,
    MalwareLookupResponse,
    IOCLookupPayload,
    IOCSearchResponse,
)
from services.aws import AWSServices

BASE_URL = "https://api.recordedfuture.com"

def generate_headers():
    return {
        "accept": "application/json",
        "content-type": "application/json",
        "X-RFToken": AWSServices.get_ssm_parameters(["/soar-api/recorded_future_api"], "ap-southeast-2")[0],
    }

def searchMalware(event: MalwareLookupPayload) -> list[MalwareLookupResponse]:
    """Searches Recorded Future for malware intelligence based on a list of SHA256 hashes."""
    data_return = []
    iocs = event.sha256_list
    payload = {"field": "sha256", "sha256_list": iocs, "start_date": "2023-11-01"}
    url = f"{BASE_URL}/malware-intelligence/v1/query_iocs"
    response = requests.post(url, json=payload, headers=generate_headers())
    json_response = response.json()
    data = json_response.get("data", [])
    if not data:
        return [MalwareLookupResponse(risk_score=0, file_extensions=[], tags=[])]
    for d in data:
        risk_score = d.get("risk_score", 0)
        file_extensions = d.get("file_extensions", [])
        tags = d.get("tags", [])
        sandbox_score = d.get("sandbox_score", 0)
        data_return.append(
            MalwareLookupResponse(
                risk_score=risk_score,
                file_extensions=file_extensions,
                tags=tags,
                sandbox_score=sandbox_score,
                hash=d.get("name")
            )
        )
    return data_return


def searchIOC(event: IOCLookupPayload) -> IOCSearchResponse:
    """Searches Recorded Future for intelligence based on a list of IOCs (hashes, domains, IPs)."""
    url = f"{BASE_URL}/soar/v3/enrichment"
    header = generate_headers()
    payload = {
        "ip": event.ip or [],
        "domain": event.domain or [],
        "hash": event.hash or []
    }
    response = requests.post(url, json=payload, headers=header)
    json_response = response.json()
    return IOCSearchResponse.model_validate(json_response)

def searchSandbox(hash: str) -> MalwareAnalysisResponse:
    """Searches Recorded Future for sandbox intelligence based on a SHA256 hash."""
    url = f"{BASE_URL}/malware-intelligence/v1/reports"
    header = generate_headers()
    payload = {
        "query": "dynamic.signatures_count > 1",
        "sha256": hash,
        "start_date": "2023-11-01"
    }
    response = requests.post(url, json=payload, headers=header)
    json_response = response.json()
    return MalwareAnalysisResponse.model_validate(json_response)

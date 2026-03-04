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
    """Build HTTP headers required for all Recorded Future API requests"""
    return {
        "accept": "application/json",
        "content-type": "application/json",
        "X-RFToken": AWSServices.get_ssm_parameters(
            ["recorded_future_api"], "ap-southeast-2"
        )[0],
    }


def searchMalware(event: MalwareLookupPayload) -> list[MalwareLookupResponse]:
    """Query malware intelligence for one or more SHA256 file hashes.

    This function calls Recorded Future's malware IOC endpoint and returns a
    normalized list of malware attributes per matched hash.

    When to call:
    - Use this MCP tool when you need malware metadata for known sample hashes
      (for example: triage enrichment, scoring, tagging, extension profiling).
    - Call when the input data is specifically SHA256 values, not generic IOC
      types like IP/domain.

    Arguments:
    - event (MalwareLookupPayload): Pydantic payload containing:
      - `sha256_list` (List[str]): One or more SHA256 hashes to query.

    Returns:
    - list[MalwareLookupResponse]: A list where each item includes:
      - `risk_score` (int)
      - `file_extensions` (List[str])
      - `tags` (List[str])
      - `sandbox_score` (Optional[int])
      - `hash` (str)
    """
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
                hash=d.get("name"),
            )
        )
    return data_return


def searchIOC(event: IOCLookupPayload) -> IOCSearchResponse:
    """Perform multi-type IOC enrichment for hashes, domains, and IP addresses.

    This function calls Recorded Future's SOAR enrichment endpoint and validates
    the response into the typed `IOCSearchResponse` model.

    When to call:
    - Use this MCP tool for general IOC enrichment workflows where inputs may
      include one or more IOC types (IP, domain, hash) in a single request.
    - Prefer this over `searchMalware` when you need broad IOC risk context
      rather than malware-sample-specific metadata.

    Arguments:
    - event (IOCLookupPayload): Pydantic payload containing:
      - `hash` (List[str]): File hashes.
      - `domain` (List[str]): Domain names.
      - `ip` (List[str]): IPv4/IPv6 addresses.

    Returns:
    - IOCSearchResponse: Parsed response containing IOC enrichment results under
      `data.results`, including entity and risk information.
    """
    url = f"{BASE_URL}/soar/v3/enrichment"
    header = generate_headers()
    payload = {"ip": event.ip or [], "domain": event.domain or [], "hash": event.hash or []}
    response = requests.post(url, json=payload, headers=header)
    json_response = response.json()
    return IOCSearchResponse.model_validate(json_response)


def searchSandbox(hash: str) -> MalwareAnalysisResponse:
    """Retrieve malware dynamic-analysis (sandbox) reports for a SHA256 hash.

    This function queries malware sandbox reports and returns behavioral analysis
    data such as signatures, network activity, processes, and extracted artifacts.

    When to call:
    - Use this MCP tool after hash triage when detailed behavioral evidence is
      needed (for example: incident investigation or malware detonation context).
    - Call when you specifically need sandbox report content, not just IOC risk
      scoring.

    Arguments:
    - hash (str): SHA256 hash of the malware sample to search.

    Returns:
    - MalwareAnalysisResponse: Parsed malware report object, typically including
      `reports[]` entries with `sample` and `dynamic` analysis details.
    """
    url = f"{BASE_URL}/malware-intelligence/v1/reports"
    header = generate_headers()
    payload = {
        "query": "dynamic.signatures_count > 1",
        "sha256": hash,
        "start_date": "2023-11-01",
    }
    response = requests.post(url, json=payload, headers=header)
    json_response = response.json()
    return MalwareAnalysisResponse.model_validate(json_response)

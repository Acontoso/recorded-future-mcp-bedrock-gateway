# Recorded Future MCP Bedrock Gateway

An AWS Lambda-based gateway that integrates AWS Bedrock Agent Core with Recorded Future's threat intelligence services. This project enables seamless threat intelligence lookups and malware analysis through Bedrock agents.

## 🎯 Overview

The **Recorded Future MCP Bedrock Gateway** is a serverless integration layer that bridges AWS Bedrock Agent Core with Recorded Future's threat intelligence APIs. It provides a unified interface for security teams to query threat data, including malware analysis, indicators of compromise (IOCs), and sandbox intelligence, directly from Bedrock-powered agents.

### Use Cases

- **Threat Intelligence Enrichment**: Enrich security investigations with real-time threat data
- **Automated Malware Analysis**: Query malware risk scores, file extensions, and sandbox signatures
- **IOC Lookup**: Search for intelligence on file hashes, domains, and IP addresses
- **Agent-Driven Security**: Enable Bedrock agents to autonomously pull threat intelligence

## ✨ Features

- **Malware Intelligence Search**: Query Recorded Future for malware data using SHA256 hashes
- **IOC Enrichment**: Look up multiple indicators of compromise (hashes, domains, IPs) in one request
- **Sandbox Analysis**: Retrieve detailed malware analysis reports from Recorded Future's sandbox
- **Lambda Integration**: Serverless deployment with minimal operational overhead
- **Pydantic Models**: Type-safe request/response handling
- **AWS SSM Parameter Store Integration**: Secure API credential management
- **JSON Logging**: CloudWatch-compatible JSON-formatted logs
- **Infrastructure as Code**: Complete Terraform deployment configuration

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   AWS Bedrock Agent Core                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│    AWS Lambda Function (recorded-future-mcp-gateway)        │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Tool Dispatcher (searchMalware, lookupIOC, searchSand) ││
│  └──────────────────────┬────────────────────────────────┬┘│
│                         │                                │  │
│  ┌──────────────────────▼─────────────────────────────┐  │  │
│  │         Recorded Future API Client                │  │  │
│  │  • generate_headers()                             │  │  │
│  │  • Model Validation (Pydantic)                    │  │  │
│  └──────────────────────┬─────────────────────────────┘  │  │
│                         │                                │  │
│  ┌──────────────────────▼─────────────────────────────┐  │  │
│  │      AWS SSM Parameter Store (API Key)            │  │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────┬────────────────────────────────┘
                          │
                          ▼
              ┌──────────────────────────┐
              │  Recorded Future API     │
              │  (SOAR v3, Malware v1)   │
              └──────────────────────────┘
```

## 📦 Prerequisites

- **Python 3.11+**
- **AWS Account** with appropriate permissions for:
  - Lambda
  - IAM
  - SSM Parameter Store
  - CloudWatch
- **Terraform 1.0+**
- **Recorded Future API Token** (stored in AWS SSM Parameter Store)
- **AWS CLI** configured with appropriate credentials

## 📁 Project Structure

```
.
├── README.md                          # This file
├── requirements.txt                   # Python dependencies
├── code/                              # Lambda function code
│   ├── __init__.py
│   ├── main.py                        # Lambda handler
│   ├── models/
│   │   ├── __init__.py
│   │   └── models.py                  # Pydantic data models
│   ├── services/
│   │   ├── __init__.py
│   │   └── aws.py                     # AWS service integrations
│   ├── tools/
│   │   ├── __init__.py
│   │   └── recordedFuture.py          # Recorded Future API client
│   └── utils/
│       ├── __init__.py
│       └── logs.py                    # Logging configuration
└── terraform/                         # Infrastructure as Code
    ├── main.tf                        # Terraform provider config
    ├── lambda.tf                      # Lambda function definition
    ├── iam.tf                         # IAM roles and policies
    ├── gateway.tf                     # API Gateway config
    ├── sns.tf                         # SNS topic configuration
    ├── locals.tf                      # Local variables
    ├── variables.tf                   # Input variables
    ├── data.tf                        # Data sources
    └── terraform.tfvars               # Variable values
```

## 🔐 Security Considerations

- **API Credentials**: Stored securely in AWS SSM Parameter Store with encryption
- **IAM Permissions**: Lambda execution role has minimal required permissions
- **HTTPS Only**: All API calls to Recorded Future use HTTPS
- **Input Validation**: All inputs validated using Pydantic models
- **Error Handling**: Sensitive information not exposed in error messages

## 📚 Dependencies

Key dependencies:

- **boto3**: AWS SDK for Python
- **requests**: HTTP client library
- **pydantic**: Data validation and settings management

See `requirements.txt` for the complete list.

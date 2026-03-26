# URL Shortener API Documentation

Complete API reference for the Serverless URL Shortener service.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Base URL](#base-url)
- [Authentication](#authentication)
- [Endpoints](#endpoints)
- [Data Models](#data-models)
- [Error Codes](#error-codes)
- [Rate Limits](#rate-limits)
- [Examples](#examples)

---

## Overview

The URL Shortener API provides a simple RESTful interface to create and manage shortened URLs. The API is built using AWS Lambda and API Gateway, offering high availability and automatic scaling.

### API Version
- **Current Version:** 1.0
- **Protocol:** HTTPS only
- **Data Format:** JSON
- **Character Encoding:** UTF-8

---

## Base URL

**Production:** `https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/prod`

> **Note:** Replace `YOUR-API-ID` with your actual API Gateway ID.

### Finding Your API URL

1. AWS Console → API Gateway
2. Select **URLShortenerAPI**
3. Stages → **prod**
4. Copy **Invoke URL**

---

## Authentication

### Current Version (v1.0)
- **Authentication:** None required
- **API Key:** Not required

### Future Versions
- Will support API key authentication
- Rate limiting per API key
- User-specific URL management

---

## Endpoints

### 1. Create Short URL

Convert a long URL into a shortened version.

#### Request

```http
POST /shorten
Content-Type: application/json
```

**Request Body:**

```json
{
  "long_url": "string"
}
```

**Parameters:**

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `long_url` | string | Yes | The original URL to shorten. Must start with `http://` or `https://` |

**Constraints:**
- URL must be valid (start with `http://` or `https://`)
- Maximum URL length: 2048 characters
- URL must be accessible (no validation performed)

#### Response

**Success (200 OK):**

```json
{
  "short_url": "https://your-api.com/prod/xK7p2L",
  "short_code": "xK7p2L",
  "long_url": "https://example.com/very/long/url",
  "message": "Short URL created successfully"
}
```

**Response Fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `short_url` | string | Complete shortened URL ready to use |
| `short_code` | string | 6-character unique identifier |
| `long_url` | string | The original URL submitted |
| `message` | string | Success confirmation message |

#### Error Responses

**400 Bad Request - Missing URL:**
```json
{
  "error": "long_url is required"
}
```

**400 Bad Request - Invalid URL Format:**
```json
{
  "error": "Invalid URL format. Must start with http:// or https://"
}
```

**400 Bad Request - Invalid JSON:**
```json
{
  "error": "Invalid JSON in request body"
}
```

**500 Internal Server Error:**
```json
{
  "error": "Internal server error",
  "message": "Detailed error message"
}
```

#### Example Request
```bash
curl -X POST https://abc123.execute-api.us-east-1.amazonaws.com/prod/shorten \
  -H "Content-Type: application/json" \
  -d '{
    "long_url": "https://docs.aws.amazon.com/lambda/latest/dg/welcome.html"
  }'
```

#### Example Response
```json
{
  "short_url": "https://abc123.execute-api.us-east-1.amazonaws.com/prod/xK7p2L",
  "short_code": "xK7p2L",
  "long_url": "https://docs.aws.amazon.com/lambda/latest/dg/welcome.html",
  "message": "Short URL created successfully"
}
```

---

### 2. Redirect to Original URL

Retrieve the original URL and redirect the user.

#### Request

```http
GET /{shortCode}
```

**Path Parameters:**

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `shortCode` | string | Yes | The 6-character short code |

**Example:** `GET /xK7p2L`

#### Response

**Success (301 Moved Permanently):**

```http
HTTP/1.1 301 Moved Permanently
Location: https://example.com/original/url
Content-Type: application/json

{
  "redirecting_to": "https://example.com/original/url"
}
```

**Response Headers:**

| Header | Value | Description |
| :--- | :--- | :--- |
| `Location` | URL string | The original URL to redirect to |
| `Content-Type` | `application/json` | Response content type |

**Side Effects:**
- Click counter incremented in database
- Redirect logged in CloudWatch

#### Error Responses

**404 Not Found:**
```json
{
  "error": "Short URL not found",
  "short_code": "invalid"
}
```

**400 Bad Request:**
```json
{
  "error": "Short code is required"
}
```

#### Example Request
```bash
curl -I https://abc123.execute-api.us-east-1.amazonaws.com/prod/xK7p2L
```

#### Example Response
```http
HTTP/2 301
date: Wed, 20 Mar 2024 10:30:00 GMT
content-type: application/json
location: https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
x-amzn-requestid: abc-def-ghi
```

**Browser Behavior:**
When accessed via browser, user is automatically redirected to the original URL.

---

## Data Models

### URL Mapping Object
Stored in DynamoDB with the following structure:

```json
{
  "short_code": "xK7p2L",
  "long_url": "https://example.com/original/url",
  "created_at": 1710931800,
  "clicks": 42
}
```

**Field Descriptions:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `short_code` | String (PK) | 6-character unique identifier (partition key) |
| `long_url` | String | Original URL |
| `created_at` | Number | Unix timestamp (seconds since epoch) |
| `clicks` | Number | Number of times URL has been accessed |

---

## Error Codes

### HTTP Status Codes

| Code | Name | Description |
| :--- | :--- | :--- |
| 200 | OK | Request successful, resource created |
| 301 | Moved Permanently | Redirect to original URL |
| 400 | Bad Request | Invalid input (missing/malformed data) |
| 404 | Not Found | Short code doesn't exist |
| 405 | Method Not Allowed | HTTP method not supported |
| 500 | Internal Server Error | Server-side error (Lambda/DynamoDB) |

### Error Response Format
All errors follow this structure:

```json
{
  "error": "Human-readable error message",
  "message": "Detailed technical message (optional)"
}
```

### Common Error Scenarios

- **Scenario 1: Missing Request Body**
  - Request: `POST /shorten` (empty body)
  - Response: `400 {"error": "long_url is required"}`

- **Scenario 2: Invalid URL**
  - Request: `POST /shorten {"long_url": "not-a-url"}`
  - Response: `400 {"error": "Invalid URL format..."}`

- **Scenario 3: Non-existent Short Code**
  - Request: `GET /invalid`
  - Response: `404 {"error": "Short URL not found", "short_code": "invalid"}`

- **Scenario 4: Lambda Timeout**
  - Response: `500 {"error": "Internal server error", "message": "Task timed out"}`

---

## Rate Limits

### Current Limits
- **API Gateway:** 10,000 requests per second (AWS default)
- **Lambda Concurrent Executions:** 1,000 (AWS account default)
- **DynamoDB:** On-demand (auto-scales)

### Throttling Response
When rate limit exceeded:

```http
HTTP/1.1 429 Too Many Requests
Content-Type: application/json

{
  "error": "Rate limit exceeded",
  "message": "Too many requests, please try again later"
}
```

**Best Practices:**
- Implement exponential backoff on 429 responses
- Cache frequently accessed URLs client-side
- Use batch operations when shortening multiple URLs

---

## Examples

### Example 1: Simple URL Shortening

**Request:**
```bash
curl -X POST https://abc123.execute-api.us-east-1.amazonaws.com/prod/shorten \
  -H "Content-Type: application/json" \
  -d '{"long_url": "https://github.com/yourusername/repo"}'
```

**Response:**
```json
{
  "short_url": "https://abc123.execute-api.us-east-1.amazonaws.com/prod/a1B2c3",
  "short_code": "a1B2c3",
  "long_url": "https://github.com/yourusername/repo",
  "message": "Short URL created successfully"
}
```

**Usage:**
```bash
# Share this URL
https://abc123.execute-api.us-east-1.amazonaws.com/prod/a1B2c3

# Anyone clicking it gets redirected to:
https://github.com/yourusername/repo
```

### Example 2: Error Handling

**Request:**
```bash
curl -X POST https://abc123.execute-api.us-east-1.amazonaws.com/prod/shorten \
  -H "Content-Type: application/json" \
  -d '{"long_url": "invalid-url"}'
```

**Response:**
```json
{
  "error": "Invalid URL format. Must start with http:// or https://"
}
```

### Example 3: JavaScript Integration

```javascript
async function shortenURL(longUrl) {
  const apiUrl = 'https://abc123.execute-api.us-east-1.amazonaws.com/prod';
  
  try {
    const response = await fetch(`${apiUrl}/shorten`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ long_url: longUrl })
    });
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error);
    }
    
    const data = await response.json();
    return data.short_url;
    
  } catch (error) {
    console.error('Error shortening URL:', error);
    throw error;
  }
}

// Usage
shortenURL('https://example.com/long/path')
  .then(shortUrl => console.log('Short URL:', shortUrl))
  .catch(error => console.error('Failed:', error));
```

### Example 4: Python Integration

```python
import requests
import json

def shorten_url(long_url):
    api_url = 'https://abc123.execute-api.us-east-1.amazonaws.com/prod'
    
    payload = {'long_url': long_url}
    headers = {'Content-Type': 'application/json'}
    
    try:
        response = requests.post(
            f'{api_url}/shorten',
            json=payload,
            headers=headers
        )
        response.raise_for_status()
        
        data = response.json()
        return data['short_url']
        
    except requests.exceptions.HTTPError as e:
        print(f"HTTP Error: {e}")
        print(f"Response: {e.response.text}")
        raise
    except Exception as e:
        print(f"Error: {e}")
        raise

# Usage
if __name__ == '__main__':
    long_url = 'https://example.com/very/long/path'
    short_url = shorten_url(long_url)
    print(f'Original: {long_url}')
    print(f'Shortened: {short_url}')
```

### Example 5: Testing Redirect

```bash
# Get redirect location without following
curl -I https://abc123.execute-api.us-east-1.amazonaws.com/prod/a1B2c3

# Follow redirect automatically
curl -L https://abc123.execute-api.us-east-1.amazonaws.com/prod/a1B2c3

# Get redirect location programmatically
curl -s -o /dev/null -w "%{redirect_url}\n" \
  https://abc123.execute-api.us-east-1.amazonaws.com/prod/a1B2c3
```

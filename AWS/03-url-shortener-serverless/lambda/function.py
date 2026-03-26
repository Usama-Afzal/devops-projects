import json
import boto3
import string
import random
from decimal import Decimal
import time

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('URLShortener')

def generate_short_code(length=6):
    """Generate a random short code"""
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(length))

def is_valid_url(url):
    """Basic URL validation"""
    return url.startswith('http://') or url.startswith('https://')

def lambda_handler(event, context):
    """Main Lambda handler"""
    
    print(f"Event: {json.dumps(event)}")  # For debugging
    
    http_method = event.get('httpMethod', event.get('requestContext', {}).get('http', {}).get('method'))
    
    try:
        if http_method == 'POST':
            return create_short_url(event)
        elif http_method == 'GET':
            return redirect_url(event)
        else:
            return {
                'statusCode': 405,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({'error': 'Method not allowed'})
            }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': 'Internal server error', 'message': str(e)})
        }

def create_short_url(event):
    """Create a new short URL"""
    
    # Parse request body
    try:
        body = json.loads(event['body'])
    except:
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': 'Invalid JSON in request body'})
        }
    
    long_url = body.get('long_url')
    
    # Validate input
    if not long_url:
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': 'long_url is required'})
        }
    
    if not is_valid_url(long_url):
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': 'Invalid URL format. Must start with http:// or https://'})
        }
    
    # Generate unique short code
    max_attempts = 5
    for attempt in range(max_attempts):
        short_code = generate_short_code()
        
        # Check if short code already exists
        try:
            response = table.get_item(Key={'short_code': short_code})
            if 'Item' not in response:
                # Short code is unique, use it
                break
        except Exception as e:
            print(f"Error checking short code: {e}")
            if attempt == max_attempts - 1:
                raise
    
    # Store in DynamoDB
    try:
        table.put_item(
            Item={
                'short_code': short_code,
                'long_url': long_url,
                'created_at': Decimal(str(time.time())),
                'clicks': 0
            }
        )
    except Exception as e:
        print(f"Error storing in DynamoDB: {e}")
        raise
    
    # Return response
    # Get API Gateway domain (will be set when we configure API Gateway)
    base_url = event.get('headers', {}).get('Host', 'your-api-gateway-url')
    stage = event.get('requestContext', {}).get('stage', 'prod')
    
    short_url = f"https://{base_url}/{stage}/{short_code}"
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'short_url': short_url,
            'short_code': short_code,
            'long_url': long_url,
            'message': 'Short URL created successfully'
        })
    }

def redirect_url(event):
    """Redirect to original URL"""
    
    # Get short code from path
    path = event.get('path', '')
    short_code = path.split('/')[-1]  # Get last part of path
    
    if not short_code:
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': 'Short code is required'})
        }
    
    # Look up in DynamoDB
    try:
        response = table.get_item(Key={'short_code': short_code})
    except Exception as e:
        print(f"Error querying DynamoDB: {e}")
        raise
    
    if 'Item' not in response:
        return {
            'statusCode': 404,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'error': 'Short URL not found',
                'short_code': short_code
            })
        }
    
    item = response['Item']
    long_url = item['long_url']
    
    # Increment click counter
    try:
        table.update_item(
            Key={'short_code': short_code},
            UpdateExpression='SET clicks = clicks + :inc',
            ExpressionAttributeValues={':inc': 1}
        )
    except Exception as e:
        # Log error but don't fail the redirect
        print(f"Error updating click count: {e}")
    
    # Return 301 redirect
    return {
        'statusCode': 301,
        'headers': {
            'Location': long_url,
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'redirecting_to': long_url
        })
    }

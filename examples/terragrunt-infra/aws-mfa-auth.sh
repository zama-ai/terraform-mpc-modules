#!/bin/bash
# Set up AWS MFA authentication
# Note: this script assumes that aws_access_key_id/aws_secret_access_key are already set in your environment, eg. in ~/.aws/credentials
set -e

# Create .aws directory if it doesn't exist
mkdir -p ~/.aws
if [ -n "$AWS_PROFILE" ]; then
  profile_name=$AWS_PROFILE
  echo "Using AWS_PROFILE environment variable: $profile_name"
else
  # Prompt for aws profile
  read -p "Enter the AWS profile name: " profile_name
fi

export AWS_PROFILE="$profile_name"
echo "Setting up MFA for $AWS_PROFILE"

# Automatically get MFA device ARN for the user
mfa_arn=$(aws iam list-mfa-devices --query 'MFADevices[0].SerialNumber' --output text)

if [ -z "$mfa_arn" ] || [ "$mfa_arn" == "None" ]; then
    echo "Error: Could not retrieve MFA device ARN. Please ensure you have an MFA device configured."
    exit 1
fi

echo "Found MFA device: $mfa_arn"

# Prompt for MFA token securely
echo -n "Enter MFA token: "
read -s mfa_token
echo  # New line after hidden input

if [ -z "$mfa_token" ]; then
    echo "Error: MFA token is required"
    exit 1
fi

# Validate that input is a number
if ! [[ "$mfa_token" =~ ^[0-9]+$ ]]; then
    echo "Error: MFA token must be a number"
    exit 1
fi

# Unset any existing AWS session tokens
unset AWS_SESSION_TOKEN
unset AWS_SECURITY_TOKEN

# Get temporary credentials using the long-term credentials
credentials=$(aws sts get-session-token \
    --serial-number "$mfa_arn" \
    --token-code "$mfa_token" \
    --duration-seconds 43200)

AWS_ACCESS_KEY_ID=$(echo "$credentials" | jq -r '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo "$credentials" | jq -r '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo "$credentials" | jq -r '.Credentials.SessionToken')

# Verify the credentials were obtained
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
    echo "Error: Failed to obtain AWS credentials"
    exit 1
fi

# Configure AWS credentials using aws configure
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile "token-$AWS_PROFILE"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile "token-$AWS_PROFILE"
aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile "token-$AWS_PROFILE"
aws configure set region "eu-west-1" --profile "token-$AWS_PROFILE"  # You can adjust the region as needed

# Configure AWS credentials using aws configure for local use
export AWS_SHARED_CREDENTIALS_FILE=~/.aws/local-credentials
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile default
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile default
aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile default
aws configure set region "eu-west-1" --profile default  # You can adjust the region as needed

echo "AWS credentials successfully configured under [token-$AWS_PROFILE] profile"

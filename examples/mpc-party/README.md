# MPC Party Only Example

This example demonstrates how to deploy only the MPC (Multi-Party Computation) party infrastructure without partner connections or service provider capabilities. It creates the essential storage and authentication components needed for an MPC party to participate in secure computations.

## What This Example Deploys

This example deploys the core MPC party infrastructure:

- **S3 Storage Buckets**: Private and public buckets for MPC data storage
- **IRSA Role** (optional): IAM role for secure AWS access from Kubernetes
- **Kubernetes Resources**: Service account, namespace, and configuration
- **ConfigMap**: Environment variables for MPC applications

## Architecture

    ```mermaid
    graph TB
        subgraph "AWS Account"
            subgraph "S3 Storage"
                PB[Private Bucket<br/>Sensitive Data]
                PUB[Public Bucket<br/>Shared Data]
            end
            
            subgraph "IAM"
                IRSA[IRSA Role<br/>S3 Permissions]
            end
        end
        
        subgraph "EKS Cluster"
            subgraph "MPC Namespace"
                SA[Service Account]
                CM[ConfigMap<br/>S3 Endpoints]
                POD[MPC Application Pod]
            end
        end
        
        IRSA -.->|assumes| SA
        SA -->|uses| POD
        CM -->|configures| POD
        POD -->|reads/writes| PB
        POD -->|reads/writes| PUB
    ```

## Prerequisites

- AWS CLI configured with appropriate permissions
- kubectl configured to access your EKS cluster
- Terraform >= 1.0 installed
- An existing EKS cluster

### Required AWS Permissions

The deploying user/role needs permissions to:

- Create and manage S3 buckets and policies
- Create IAM roles and policies (if using IRSA)
- Access EKS cluster for Kubernetes resources
- Create VPC interface endpoints (if using networking modules)

## Quick Start

1. **Clone and Navigate**

    ```bash
    git clone <repository-url>
    cd terraform-mpc-modules/examples/mpc-party-only
    ```

2. **Configure Variables**

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    # Edit terraform.tfvars with your configuration
    ```

3. **Initialize and Deploy**

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `party_name` | Name of the MPC party | `"alice-party"` |
| `cluster_name` | EKS cluster name | `"my-eks-cluster"` |

### Key Configuration Options

#### IRSA (Recommended for Production)

    ```hcl
    create_irsa = true
    ```

- Enables secure AWS access from Kubernetes pods
- No need to manage AWS credentials manually
- Follows AWS security best practices

#### Custom S3 Bucket Naming

    ```hcl
    bucket_prefix = "my-company-mpc-vault"
    party_name = "alice-party"
    environment = "prod"
    ```

Results in buckets like:
- `my-company-mpc-vault-private-alice-party-prod-a1b2c3d4`
- `my-company-mpc-vault-public-alice-party-prod-a1b2c3d4`

#### Kubernetes Configuration

    ```hcl
    namespace = "mpc-party"
    service_account_name = "mpc-party-sa"
    create_namespace = true
    ```

## Usage After Deployment

### 1. Verify Deployment

Check S3 buckets:

    ```bash
    aws s3 ls | grep <party-name>
    ```

Check Kubernetes resources:

    ```bash
    kubectl get sa,configmap -n mpc-party
    ```

### 2. Deploy MPC Application

Use the provided configuration in your MPC application deployment:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: mpc-application
      namespace: mpc-party
    spec:
      template:
        metadata:
          annotations:
            eks.amazonaws.com/role-arn: "<irsa-role-arn>"
        spec:
          serviceAccountName: mpc-party-sa
          containers:
          - name: mpc-app
            image: your-mpc-app:latest
            envFrom:
            - configMapRef:
                name: mpc-party-config-<party-name>
    ```

### 3. Environment Variables

The deployment creates a ConfigMap with these environment variables:

- `KMS_CORE__PUBLIC_VAULT__STORAGE`: S3 URI for public bucket
- `KMS_CORE__PRIVATE_VAULT__STORAGE`: S3 URI for private bucket

### 4. S3 Access Patterns

#### Private Bucket Usage

    ```bash
    # Store sensitive computation data
    aws s3 cp sensitive-data.enc s3://<private-bucket>/party-data/
    ```

#### Public Bucket Usage

    ```bash
    # Store shared computation results
    aws s3 cp results.json s3://<public-bucket>/shared-results/
    ```

## Security Considerations

### S3 Bucket Policies

- **Private Bucket**: Access restricted to the IRSA role only
- **Public Bucket**: Read access for all, write access via IRSA role

### IRSA Security

- Follows principle of least privilege
- Scoped to specific S3 buckets only
- No broader AWS permissions granted

### Network Security

- This example focuses on storage only
- For network connectivity to partners, see `partner-consumer` or `partner-provider` examples

## Troubleshooting

### Common Issues

#### S3 Access Denied

    ```bash
    # Check IRSA role permissions
    kubectl describe sa mpc-party-sa -n mpc-party
    
    # Verify role annotations
    kubectl get sa mpc-party-sa -n mpc-party -o yaml
    ```

#### ConfigMap Not Found

    ```bash
    # Check if ConfigMap exists
    kubectl get configmap -n mpc-party
    
    # View ConfigMap contents
    kubectl describe configmap mpc-party-config-<party-name> -n mpc-party
    ```

#### Kubernetes Authentication

    ```bash
    # Test cluster access
    kubectl get nodes
    
    # Check current context
    kubectl config current-context
    ```

## Scaling and Production Considerations

### Multi-Environment Setup

Deploy separate instances for different environments:

    ```bash
    # Development
    terraform workspace new dev
    terraform apply -var="environment=dev" -var="party_name=alice-dev"
    
    # Production  
    terraform workspace new prod
    terraform apply -var="environment=prod" -var="party_name=alice-prod"
    ```

### Backup and Recovery

Consider implementing:

- S3 bucket versioning (enabled by default)
- Cross-region replication for critical data
- Regular backup procedures for private bucket data

### Monitoring

Recommended monitoring setup:

- CloudWatch metrics for S3 bucket access
- Kubernetes resource monitoring
- Application-level MPC computation metrics

## Integration with Other Examples

This example can be combined with:

- **Partner Consumer**: Add partner connectivity to consume external MPC services
- **Partner Provider**: Add service provider capabilities to offer MPC services
- **Custom networking**: Integrate with VPC endpoint configurations

## Cleanup

To destroy all resources:

    ```bash
    terraform destroy
    ```

**Warning**: This will permanently delete S3 buckets and all data. Ensure you have backups if needed.

## Next Steps

1. **Deploy MPC Application**: Use the storage infrastructure to deploy your MPC computation workload
2. **Add Partner Connectivity**: Extend with partner-consumer or partner-provider examples
3. **Implement Monitoring**: Add CloudWatch and Kubernetes monitoring
4. **Production Hardening**: Review security settings and add additional safeguards

## Support

For issues and questions:

- Check the main module documentation
- Review AWS EKS and S3 best practices
- Consult MPC application documentation for specific integration guidance 
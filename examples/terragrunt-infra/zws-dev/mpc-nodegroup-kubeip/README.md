# MPC Node Group with KubeIP - ZWS Development Environment

## Overview

This configuration deploys the complete MPC infrastructure for the ZWS development environment, including:

- **Dedicated EKS Node Group**: Public subnet placement for internet connectivity
- **Security Groups**: MPC-specific port configuration (50001, 50100, 9646)
- **KubeIP**: Automatic Elastic IP assignment to enclave nodes

## Prerequisites

### 1. Elastic IPs
Ensure the `mpc-elastic-ip` module has been deployed first:

```bash
cd ../mpc-elastic-ip
terragrunt apply
```

This creates tagged Elastic IPs that KubeIP will discover and assign.

### 2. EKS Cluster
Verify the target EKS cluster (`zws-dev-cluster`) exists and is accessible.

### 3. SSH Key Pair
Ensure the SSH key pair `zws-dev-keypair` exists in the AWS account for node access.

## Deployment

```bash
# Initialize and plan
terragrunt init
terragrunt plan

# Deploy the infrastructure  
terragrunt apply

# Verify deployment
terragrunt output
```

## Configuration Details

### MPC Ports
- **50001**: MPC P2P TCP communication
- **50100**: MPC gRPC port
- **9646**: MPC metrics port

### Node Group
- **Instance Types**: `t3.medium`, `t3.large` (SPOT for cost optimization)
- **Capacity**: 2 desired, 1-3 range
- **Placement**: Public subnets for EIP assignment

### KubeIP
- **EIP Filter**: Matches tags from `mpc-elastic-ip` module
- **Target Nodes**: Enclave nodes with `kubeip=use` label
- **Logging**: Debug level for development troubleshooting

## Security Considerations

⚠️ **Development Configuration**
- SSH access enabled from VPC (10.0.0.0/8)
- Peer access open (0.0.0.0/0) - **RESTRICT IN PRODUCTION**
- Debug logging enabled

## Verification

### Check Node Group
```bash
kubectl get nodes -l nodepool=mpc-enclave
```

### Verify KubeIP
```bash
# Check KubeIP pods
kubectl get pods -n kube-system -l app.kubernetes.io/name=kubeip

# Check IP assignments
kubectl get nodes -o wide

# View KubeIP logs
kubectl logs -n kube-system -l app.kubernetes.io/name=kubeip
```

### Test MPC Connectivity
```bash
# Check security group rules
aws ec2 describe-security-groups --filters "Name=tag:Component,Values=firewall"

# Test port connectivity (from within cluster)
telnet <node-ip> 50001
telnet <node-ip> 50100
telnet <node-ip> 9646
```

## Troubleshooting

### KubeIP Issues
1. **No IP Assignment**: Check EIP tags match filter configuration
2. **Pod Scheduling**: Verify node labels and taints
3. **Permissions**: Ensure IRSA role has EC2 permissions

### Node Group Issues
1. **Nodes Not Ready**: Check subnet routing and security groups
2. **Spot Interruptions**: Monitor for capacity notifications
3. **SSH Access**: Verify key pair and security group rules

## Next Steps

After successful deployment:
1. Deploy MPC applications to the enclave nodes
2. Configure peer connectivity with other participants
3. Set up monitoring and alerting
4. Plan production migration with restricted security rules

## Related Modules

- `../mpc-elastic-ip/`: Creates the Elastic IPs for KubeIP
- `../mpc-party/`: Deploys MPC party infrastructure
- `../mpc-network-provider/`: Configures network load balancer services
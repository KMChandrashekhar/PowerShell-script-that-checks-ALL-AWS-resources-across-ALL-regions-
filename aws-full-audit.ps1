Write-Host "================ AWS Full Resource & Cost Audit ================" -ForegroundColor Yellow

# --------------------------
# 1. Get list of regions
# --------------------------
$regionsText = aws ec2 describe-regions --query "Regions[].RegionName" --output text
$regions = $regionsText -split "\s+"

Write-Host "`nRegions detected: $($regions -join ', ')`n" -ForegroundColor Cyan


# --------------------------
# 2. GLOBAL SERVICES (not region-specific)
# --------------------------
Write-Host "====== GLOBAL SERVICES ======" -ForegroundColor Yellow

# S3 Buckets
Write-Host "`n--- S3 Buckets ---"
aws s3 ls

# CloudTrail
Write-Host "`n--- CloudTrail Trails ---"
aws cloudtrail describe-trails --query "trailList[].Name"


# --------------------------
# 3. SERVICES PER REGION
# --------------------------
foreach ($region in $regions) {

    Write-Host "`n======================================================" -ForegroundColor Green
    Write-Host "Checking Region: $region"
    Write-Host "======================================================`n"

    # EC2 Instances
    Write-Host "--- EC2 INSTANCES ---"
    aws ec2 describe-instances --region $region --query "Reservations[].Instances[].InstanceId"

    # EBS Volumes
    Write-Host "`n--- EBS VOLUMES ---"
    aws ec2 describe-volumes --region $region --query "Volumes[].{ID:VolumeId,State:State}"

    # Snapshots
    Write-Host "`n--- EBS SNAPSHOTS ---"
    aws ec2 describe-snapshots --owner-ids self --region $region --query "Snapshots[].SnapshotId"

    # Elastic IPs
    Write-Host "`n--- ELASTIC IPs ---"
    aws ec2 describe-addresses --region $region --query "Addresses[].PublicIp"

    # NAT Gateways
    Write-Host "`n--- NAT GATEWAYS ---"
    aws ec2 describe-nat-gateways --region $region --query "NatGateways[].NatGatewayId"

    # Load Balancers
    Write-Host "`n--- LOAD BALANCERS (ELBv2) ---"
    aws elbv2 describe-load-balancers --region $region --query "LoadBalancers[].LoadBalancerName"

    # Classic Load Balancers
    Write-Host "`n--- CLASSIC LOAD BALANCERS (ELB) ---"
    aws elb describe-load-balancers --region $region --query "LoadBalancerDescriptions[].LoadBalancerName"

    # RDS DB Instances
    Write-Host "`n--- RDS INSTANCES ---"
    aws rds describe-db-instances --region $region --query "DBInstances[].DBInstanceIdentifier"

    # Lambda
    Write-Host "`n--- LAMBDA FUNCTIONS ---"
    aws lambda list-functions --region $region --query "Functions[].FunctionName"

    # VPC Endpoints
    Write-Host "`n--- VPC ENDPOINTS ---"
    aws ec2 describe-vpc-endpoints --region $region --query "VpcEndpoints[].VpcEndpointId"

    # CloudWatch Log Groups
    Write-Host "`n--- CLOUDWATCH LOG GROUPS ---"
    aws logs describe-log-groups --region $region --query "logGroups[].logGroupName"

    # API Gateway
    Write-Host "`n--- API GATEWAYS ---"
    aws apigateway get-rest-apis --region $region --query "items[].id"

    # ECS Clusters
    Write-Host "`n--- ECS CLUSTERS ---"
    aws ecs list-clusters --region $region --query "clusterArns[]"

    # ECR Repositories
    Write-Host "`n--- ECR REPOSITORIES ---"
    aws ecr describe-repositories --region $region --query "repositories[].repositoryName"
}

Write-Host "`n================ AUDIT COMPLETE ================" -ForegroundColor Yellow

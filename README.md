# PowerShell-script-that-checks-ALL-AWS-resources-across-ALL-regions-
PowerShell script that checks ALL AWS resources across ALL regions and saves the entire output into a text file

# Get all AWS regions
$regions = (aws ec2 describe-regions --query "Regions[].RegionName" --output text).Split()

foreach ($region in $regions) {
    Write-Host "`n==================== $region ====================" -ForegroundColor Cyan

    Write-Host "`n--- EC2 Instances ---"
    aws ec2 describe-instances --region $region `
        --query "Reservations[].Instances[].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags]" `
        --output table

    Write-Host "`n--- EBS Volumes ---"
    aws ec2 describe-volumes --region $region `
        --query "Volumes[].[VolumeId,State,Size,VolumeType]" `
        --output table

    Write-Host "`n--- AMIs Owned ---"
    aws ec2 describe-images --owners self --region $region `
        --query "Images[].[ImageId,Name,CreationDate]" `
        --output table

    Write-Host "`n--- Elastic IPs ---"
    aws ec2 describe-addresses --region $region --output table

    Write-Host "`n--- Load Balancers (ALB/NLB) ---"
    aws elbv2 describe-load-balancers --region $region --output table

    Write-Host "`n--- RDS Instances ---"
    aws rds describe-db-instances --region $region --output table

    Write-Host "`n--- EKS Clusters ---"
    aws eks list-clusters --region $region --output table

    Write-Host "`n--- NAT Gateways ---"
    aws ec2 describe-nat-gateways --region $region `
        --query "NatGateways[].[NatGatewayId,State,ConnectivityType]" `
        --output table

    Write-Host "`n--- VPCs ---"
    aws ec2 describe-vpcs --region $region --output table

    Write-Host "`n--- Subnets ---"
    aws ec2 describe-subnets --region $region --output table

    Write-Host "`n--- Internet Gateways ---"
    aws ec2 describe-internet-gateways --region $region --output table

    Write-Host "`n--- Security Groups ---"
    aws ec2 describe-security-groups --region $region --output table

    Write-Host "`n--- Lambda Functions ---"
    aws lambda list-functions --region $region --output table

    Write-Host "`n--- CloudFormation Stacks ---"
    aws cloudformation list-stacks --region $region `
        --query "StackSummaries[].[StackName,StackStatus]" `
        --output table
}

# Global Services
Write-Host "`n==================== GLOBAL SERVICES ====================" -ForegroundColor Yellow

Write-Host "`n--- S3 Buckets (Global) ---"
aws s3 ls

Write-Host "`n--- Route53 Hosted Zones (Global) ---"
aws route53 list-hosted-zones --output table



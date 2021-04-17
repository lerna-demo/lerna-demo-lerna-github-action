# lerna-github-action


- place file at .github/workflows/dev-build.yml

- create ECR repo with name lerna-kubectl
- create IAM user named github-action-user
- with permission AWS-managed “AmazonEC2ContainerRegistryPowerUser” policy and 

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": "*"
        }
    ]
}


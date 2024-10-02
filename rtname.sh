#!/bin/bash

# 모든 VPC 정보 출력
echo "VPC Name and Routing Tables:"
echo "============================"

# VPC 목록 가져오기
VPCS=$(aws ec2 describe-vpcs --query "Vpcs[*].VpcId" --output text)

# 각 VPC에 대해 이름과 라우팅 테이블 정보 출력
for VPC_ID in $VPCS; do
  # VPC 이름 확인
  VPC_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$VPC_ID" "Name=key,Values=Name" --query "Tags[0].Value" --output text)

  if [ "$VPC_NAME" == "None" ]; then
    VPC_NAME="Unnamed VPC"
  fi

  echo "VPC Name: $VPC_NAME (VPC ID: $VPC_ID)"

  # 해당 VPC에 속한 라우팅 테이블 목록 가져오기
  ROUTE_TABLES=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[*].RouteTableId" --output text)

  for ROUTE_TABLE_ID in $ROUTE_TABLES; do
    # 라우팅 테이블 이름 확인
    ROUTE_TABLE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$ROUTE_TABLE_ID" "Name=key,Values=Name" --query "Tags[0].Value" --output text)

    if [ "$ROUTE_TABLE_NAME" == "None" ]; then
      ROUTE_TABLE_NAME="Unnamed Route Table"
    fi

    echo "  - Route Table Name: $ROUTE_TABLE_NAME (Route Table ID: $ROUTE_TABLE_ID)"
  done
  echo "============================"
done
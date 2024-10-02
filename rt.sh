#!/bin/bash

# VPC 이름과 라우팅 테이블 이름을 입력받음
VPC_NAME=$1
ROUTE_TABLE_NAME=$2

if [ -z "$VPC_NAME" ] || [ -z "$ROUTE_TABLE_NAME" ]; then
  echo "Usage: $0 <VPC_NAME> <ROUTE_TABLE_NAME>"
  exit 1
fi

# VPC ID 확인
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --query "Vpcs[0].VpcId" --output text)

if [ "$VPC_ID" == "None" ]; then
  echo "VPC with name $VPC_NAME not found."
  exit 1
fi

echo "VPC Name: $VPC_NAME"
echo "VPC ID: $VPC_ID"

# 라우팅 테이블 ID 확인
ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=$ROUTE_TABLE_NAME" --query "RouteTables[0].RouteTableId" --output text)

if [ "$ROUTE_TABLE_ID" == "None" ]; then
  echo "Route table with name $ROUTE_TABLE_NAME not found in VPC $VPC_NAME."
  exit 1
fi

echo "Route Table Name: $ROUTE_TABLE_NAME"
echo "Route Table ID: $ROUTE_TABLE_ID"
echo "==========================="

# 라우팅 테이블의 라우트 정보 출력
aws ec2 describe-route-tables --route-table-ids $ROUTE_TABLE_ID --query 'RouteTables[*].Routes[*]' --output table

echo "==========================="
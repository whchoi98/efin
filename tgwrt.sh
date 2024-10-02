#!/bin/bash

# 모든 Transit Gateway 정보 출력
echo "Transit Gateway Routing Tables:"
echo "==============================="

# Transit Gateway 목록 가져오기
TGWS=$(aws ec2 describe-transit-gateways --query "TransitGateways[*].TransitGatewayId" --output text)

# 각 Transit Gateway에 대해 라우팅 테이블 정보 출력
for TGW_ID in $TGWS; do
  # Transit Gateway 이름 확인
  TGW_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$TGW_ID" "Name=key,Values=Name" --query "Tags[0].Value" --output text)

  if [ "$TGW_NAME" == "None" ]; then
    TGW_NAME="Unnamed Transit Gateway"
  fi

  echo "Transit Gateway Name: $TGW_NAME (Transit Gateway ID: $TGW_ID)"
  echo "======================================================================================"

  # 해당 Transit Gateway에 속한 라우팅 테이블 목록 가져오기
  ROUTE_TABLES=$(aws ec2 describe-transit-gateway-route-tables --filters "Name=transit-gateway-id,Values=$TGW_ID" --query "TransitGatewayRouteTables[*].TransitGatewayRouteTableId" --output text)

  for ROUTE_TABLE_ID in $ROUTE_TABLES; do
    # 라우팅 테이블 이름 확인
    ROUTE_TABLE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$ROUTE_TABLE_ID" "Name=key,Values=Name" --query "Tags[0].Value" --output text)

    if [ "$ROUTE_TABLE_NAME" == "None" ]; then
      ROUTE_TABLE_NAME="Unnamed Route Table"
    fi

    echo "  - Route Table Name: $ROUTE_TABLE_NAME (Route Table ID: $ROUTE_TABLE_ID)"
    echo "    Routes:"
    echo "--------------------------------------------------------------------------------------"
    printf "| %-15s | %-25s | %-10s | %-10s | %-10s | %-10s |\n" "Destination" "Attachment ID" "VPC Name" "Resource" "Route Type" "State"
    echo "--------------------------------------------------------------------------------------"

    aws ec2 search-transit-gateway-routes --transit-gateway-route-table-id $ROUTE_TABLE_ID --filters Name=state,Values=active --query 'Routes[*].[DestinationCidrBlock, TransitGatewayAttachments[0].ResourceId, TransitGatewayAttachments[0].ResourceType, Type, State]' --output text | while read -r DEST_CIDR ATTACHMENT_ID RESOURCE_TYPE ROUTE_TYPE ROUTE_STATE; do
      if [ "$ATTACHMENT_ID" != "None" ]; then
        VPC_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$ATTACHMENT_ID" "Name=key,Values=Name" --query "Tags[0].Value" --output text)
        if [ "$VPC_NAME" == "None" ]; then
          VPC_NAME="Unnamed VPC"
        fi
      else
        VPC_NAME="None"
      fi

      # 테이블 형태로 출력
      printf "| %-15s | %-25s | %-10s | %-10s | %-10s | %-10s |\n" "$DEST_CIDR" "$ATTACHMENT_ID" "$VPC_NAME" "$RESOURCE_TYPE" "$ROUTE_TYPE" "$ROUTE_STATE"
    done

    echo "--------------------------------------------------------------------------------------"
  done

  echo "======================================================================================"
done
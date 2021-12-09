#!/bin/sh

# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Variables
USER_POOL_ID=""
APP_CLIENT_ID=""
USERNAME=""
PASSWORD=""
PROFILE_PARAM="--profile"
PROFILE_NAME=""

echo -e "${BLUE}This Script will help you to reset your ${PURPLE}AWS Cognito${BLUE} password${NC}";

echo "Enter your AWS prefered profile (--profile) leave blank for default: "
read PROFILE_NAME

if ["${PROFILE_NAME}" == ""]; then
    PROFILE_PARAM = ""
fi

echo "Enter your cognito username: "
read USERNAME

echo "Enter your cognito password: "
read PASSWORD

AWS_RESPONSE=$(aws cognito-idp admin-initiate-auth --user-pool-id ${USER_POOL_ID} --client-id ${APP_CLIENT_ID} --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME=${USERNAME},PASSWORD=${PASSWORD} ${PROFILE_PARAM} ${PROFILE_NAME})

echo $AWS_RESPONSE

SESSION_TOKEN=$(echo $AWS_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['Session'])")

echo $SESSION_TOKEN

echo "Enter your new password: "
read NEW_PASSWORD

aws cognito-idp admin-respond-to-auth-challenge --user-pool-id $USER_POOL_ID --client-id $APP_CLIENT_ID --challenge-name NEW_PASSWORD_REQUIRED --challenge-responses NEW_PASSWORD=$NEW_PASSWORD,USERNAME=$USERNAME --session "$SESSION_TOKEN" "$PROFILE_PARAM" "$PROFILE_NAME"

echo -e "All set: ${USERNAME} now has a password of ${NEW_PASSWORD}"
# AWS CLI SOLUTION
# aws cognito-idp admin-set-user-password
#   --user-pool-id <your-user-pool-id> \
#   --username <username> \
#   --password <password> \
#   --permanent
#!/usr/bin/env bash

LOG_GROUP_NAME=""
LIMIT=2000
TIME_RANGE=300
QUERY=".*"
OUTPUT_PATH=""
REGION="ap-southeast-2"

while getopts ":h :g: :t: :l: :q: :r: :o:" opt; do
  case $opt in
    h)
      echo "Usage:"
      echo "  Expects aws profile to be set in execution environment."
      echo "  All flags are optional - see defaults below."
      echo ""
      echo "Dependencies:"
      echo "  aws-cli"
      echo "  fzf"
      echo "  jq"
      echo ""
      echo "Options:"
      echo "  -g,       Specify name of log group to search.              Default: select from list"
      echo "  -l,       Specify message limit.                            Default: 2000"
      echo "  -t,       Time range in seconds, offset from surrent time.  Default: 300"
      echo "  -q,       Query string passed as filter. Parsed as RegExp.  Default: .*"
      echo "  -o,       Specify path to output raw log data.              Default: No Output"
      echo "  -r,       Region.                                           Default: ap-southeast-2"
      echo ""
      echo "Example:"
      echo "  cwlogs -g \"/aws/lambda/my-function\" -l 2000 -t 300 -q \"Error|Exception|5\\d\\d\" -r \"us-east-1\""
      exit 0
      ;;
    g) LOG_GROUP_NAME=$OPTARG ;;
    l) LIMIT=$OPTARG ;;
    t) TIME_RANGE=$OPTARG ;;
    q) QUERY=$OPTARG ;;
    o) OUTPUT_PATH=$OPTARG ;;
    r) REGION=$OPTARG ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 0
      ;;
  esac
done

if [ -z $LOG_GROUP_NAME ]; then
  LOG_GROUP_NAME=$(aws logs describe-log-groups --region $REGION | jq -r '.logGroups | .[].logGroupName' | fzf)
fi

NOW=$(date +%s)
QUERY_ID=$(
  aws logs start-query --log-group-name $LOG_GROUP_NAME \
  --start-time $(expr $NOW - $TIME_RANGE) --end-time $NOW --region $REGION \
  --query-string "fields @timestamp, @message \
    | sort @timestamp desc \
    | limit ${LIMIT} \
    | filter @message like /(?i)(${QUERY})/" \
  | jq -r '.queryId'
)

COMPLETE=""
while [ "${COMPLETE}" != "Complete" ]; do
  sleep .5
  RESULT=$(aws logs get-query-results --query-id $QUERY_ID --region $REGION)
  COMPLETE=$(echo $RESULT | jq -r '.status')
done

echo $OUTPUT_PATH
if [ -n "${OUTPUT_PATH}" ]; then
  echo $RESULT > "${OUTPUT_PATH}/${NOW}.json"
fi

echo $RESULT | jq '.results | .[] | "[\(.[0].value)]: \(.[1].value)"' | fzf --preview 'echo {}' --preview-window 'down:70%:wrap'

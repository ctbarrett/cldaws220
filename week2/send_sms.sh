#!/usr/bin/bash
#
# send_sms
#
# Simple script to send SMS messages via SNS topic, using the AWS cli utility.
#

script_filename=${0##*/}
script_dirname=${0%/*}
script=${script_filename/.sh$//}

function usage {
  echo "Usage: ${script} -t '<topic_arn>' -m '<message>'" >&2
  exit 1
}

if [[ $# -ne 4 ]]; then
  usage
fi

while getopts :t:m: OPT
do
  case $OPT in
    t) topic_arn="$OPTARG" ;;
    m) message="$OPTARG" ;;
    \*|\?) echo "Error: Invalid Option $OPTARG" >&2
           usage ;;
  esac
done

# Use subject/message format to enforce SMS character limits, and allow for
# extending to handle sending longer messages to topics with email endpoints
# later
aws sns publish --topic-arn "$topic_arn" --subject "$message" --message "$message"

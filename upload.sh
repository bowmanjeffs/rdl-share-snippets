#!/bin/sh
# Some nice variables
targetemail="anemail@ucsd.edu"
api_key="youneedakey"
server="rdl-share.ucsd.edu"
current_date=$(date -v +7d +%Y-%m-%d)

fullpath=$1
filename=`basename ${fullpath}`

if [ -z ${fullpath} ]; then
  echo "You need to provide a filename."
  exit
fi

if [ ! -f ${fullpath} ]; then
  echo "Source file/path does not exist or is not accessible."
  exit
fi

# Uploading the actual file and get attachment id for each file
# attachment_id=`curl -X POST --user "$api_key:x" -F Filedata=@$1 $server/attachments`

attachment_id=`curl -X POST --user "$api_key:x" -H "Accept: application/json" \
  -H "Content-Type: application/json" --data-binary "@${fullpath}" \
  https://${server}/attachments/binary_upload?filename=${filename}  | cut -d ':' -f 3 | cut -d '"' -f 2`

echo $attachment_id

# Attach the file to a message in the inbox
cat <<EOF | curl -k -X POST -H "Content-Type: application/json" --user "$api_key:x" -d @- https://${server}/message
{"message":
 {
  "recipients":["$targetemail"],
  "subject":"File Upload",
  "message":"File Upload",
  "expires_at":"$current_date",
  "send_email":false,
  "authorization":3,
  "attachments":["$attachment_id"]
 }
}
EOF

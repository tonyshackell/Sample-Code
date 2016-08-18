# Usage:
# test-net.sh <url> 
# 
# tests for internet connectivity by repeatedly pinging the specified URL and creating a terminal bell when the connection is successful. (Very useful in Ghana)

echo "waiting for the internet gods to smile upon us..."
ping -o $1 &> /dev/null
while [[ $? -ne 0 ]]; do
    sleep 1
    ping -o google.ca &> /dev/null
done

echo "Internet is back!" | wall

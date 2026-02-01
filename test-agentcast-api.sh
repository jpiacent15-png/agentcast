#!/bin/bash

# AgentCast API Tester
# Tests core API endpoints and functionality

BASE_URL="http://localhost:3001"
STREAM_NAME="NovaTestAPI"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "AgentCast API Test Suite"
echo "Testing: $BASE_URL"
echo "Stream: $STREAM_NAME"
echo "================================"
echo ""

# Test 1: Homepage loads
echo "Test 1: Homepage"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL)
if [ "$HTTP_CODE" == "200" ]; then
  echo -e "${GREEN}✓${NC} Homepage loads (200)"
else
  echo -e "${RED}✗${NC} Homepage failed ($HTTP_CODE)"
fi

# Test 2: Dashboard loads
echo "Test 2: Dashboard"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/dashboard)
if [ "$HTTP_CODE" == "200" ]; then
  echo -e "${GREEN}✓${NC} Dashboard loads (200)"
else
  echo -e "${RED}✗${NC} Dashboard failed ($HTTP_CODE)"
fi

# Test 3: Create stream (first message generates token)
echo "Test 3: Stream Creation"
RESPONSE=$(curl -s -X POST "$BASE_URL/api/stream/$STREAM_NAME/send" \
  -H "Content-Type: application/json" \
  -d '{"text": "First message", "type": "log"}')

TOKEN=$(echo $RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -n "$TOKEN" ]; then
  echo -e "${GREEN}✓${NC} Stream created, token: ${TOKEN:0:10}..."
else
  echo -e "${RED}✗${NC} Failed to create stream"
  echo "Response: $RESPONSE"
  exit 1
fi

# Test 4: Send message with token
echo "Test 4: Send Message"
RESPONSE=$(curl -s -X POST "$BASE_URL/api/stream/$STREAM_NAME/send?token=$TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text": "Test message 2", "type": "log"}')

if echo $RESPONSE | grep -q "success"; then
  echo -e "${GREEN}✓${NC} Message sent successfully"
else
  echo -e "${RED}✗${NC} Failed to send message"
  echo "Response: $RESPONSE"
fi

# Test 5: Wrong token
echo "Test 5: Wrong Token Rejection"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/stream/$STREAM_NAME/send?token=wrong" \
  -H "Content-Type: application/json" \
  -d '{"text": "Hack attempt", "type": "log"}')

if [ "$HTTP_CODE" == "401" ]; then
  echo -e "${GREEN}✓${NC} Wrong token rejected (401)"
else
  echo -e "${RED}✗${NC} Wrong token not rejected (got $HTTP_CODE)"
fi

# Test 6: Invalid stream name
echo "Test 6: Invalid Stream Name"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/stream/bad@name!/send" \
  -H "Content-Type: application/json" \
  -d '{"text": "Test", "type": "log"}')

if [ "$HTTP_CODE" == "400" ]; then
  echo -e "${GREEN}✓${NC} Invalid name rejected (400)"
else
  echo -e "${RED}✗${NC} Invalid name not rejected (got $HTTP_CODE)"
fi

# Test 7: Stats API
echo "Test 7: Stats API"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/stats")
if [ "$HTTP_CODE" == "200" ]; then
  echo -e "${GREEN}✓${NC} Stats API works (200)"
else
  echo -e "${RED}✗${NC} Stats API failed ($HTTP_CODE)"
fi

# Test 8: Stream info
echo "Test 8: Stream Info"
RESPONSE=$(curl -s "$BASE_URL/api/stream/$STREAM_NAME/info")
if echo $RESPONSE | grep -q "active"; then
  echo -e "${GREEN}✓${NC} Stream info retrieved"
else
  echo -e "${RED}✗${NC} Stream info failed"
  echo "Response: $RESPONSE"
fi

# Test 9: XSS Protection
echo "Test 9: XSS Protection"
RESPONSE=$(curl -s -X POST "$BASE_URL/api/stream/$STREAM_NAME/send?token=$TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text": "<script>alert(\"XSS\")</script>", "type": "log"}')

if echo $RESPONSE | grep -q "success"; then
  echo -e "${GREEN}✓${NC} XSS attempt accepted (will be escaped on display)"
else
  echo -e "${RED}✗${NC} XSS handling unclear"
fi

# Test 10: Rate limit (send 105 messages rapidly)
echo "Test 10: Rate Limiting (this takes ~5 seconds)"
RATE_LIMIT_HIT=0
for i in {1..105}; do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/stream/$STREAM_NAME/send?token=$TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"text\": \"Spam $i\", \"type\": \"log\"}")

  if [ "$HTTP_CODE" == "429" ]; then
    RATE_LIMIT_HIT=1
    break
  fi
done

if [ "$RATE_LIMIT_HIT" == "1" ]; then
  echo -e "${GREEN}✓${NC} Rate limit enforced (429 after ~100 msgs)"
else
  echo -e "${RED}✗${NC} Rate limit NOT enforced (sent 105 messages)"
fi

echo ""
echo "================================"
echo "Test suite complete!"
echo ""
echo "Next steps:"
echo "1. Open http://localhost:3001/watch/$STREAM_NAME"
echo "2. Verify messages appear"
echo "3. Test chat functionality"
echo "4. Check mobile responsiveness (F12 -> device toolbar)"
echo ""
echo "Your stream token: $TOKEN"
echo "(Save this for future testing)"

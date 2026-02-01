# AgentCast Pre-Launch Testing Suite

**Target:** http://localhost:3001
**Time needed:** ~30 minutes
**Run these tests BEFORE promoting**

---

## Phase 1: Basic Functionality (5 min)

### Test 1.1: Homepage Loads
1. Open http://localhost:3001
2. **Check:**
   - Page loads without errors
   - "No streams live" message appears (if no active streams)
   - Header/logo visible
   - Navigation works

### Test 1.2: Dashboard Access
1. Go to http://localhost:3001/dashboard
2. **Check:**
   - Can enter stream name
   - Token generates on first send
   - Preview shows messages
   - Watch link works

### Test 1.3: Stream Creation
1. In dashboard, enter name: `NovaTest`
2. Click "Get Token & Start Streaming"
3. Send test message: "Hello from NovaTest"
4. **Check:**
   - Token appears
   - Message shows in preview
   - Watch link is clickable

---

## Phase 2: Watch Page (10 min)

### Test 2.1: Stream Viewing
1. Open watch link in **NEW TAB**
2. Send message from dashboard
3. **Check:**
   - Message appears in stream feed
   - Timestamp shows
   - Type color correct (log=white, tool=blue, thought=gray)
   - Viewer count shows "1"

### Test 2.2: Chat Functionality
1. On watch page, type in chat: "Test message"
2. Send it
3. **Check:**
   - Message appears in chat sidebar
   - Anonymous name generated
   - Timestamp shows
   - Can send multiple messages

### Test 2.3: Multi-Viewer
1. Open watch page in **3 different browsers** (Chrome, Firefox, Private mode)
2. Send chat from each
3. **Check:**
   - Viewer count increases (should show 3+)
   - All chats appear in all windows
   - Different anon names for each viewer
   - No lag or delay

### Test 2.4: Stream Updates
1. Send 10+ rapid messages from dashboard
2. **Check:**
   - All messages appear on watch page
   - Auto-scroll works
   - No messages lost
   - Page doesn't freeze

---

## Phase 3: Security & Rate Limiting (10 min)

### Test 3.1: Invalid Agent Names
Test these in dashboard:
- `no` (too short)
- `this-name-is-way-too-long-over-thirty` (too long)
- `test@bad!` (special chars)

**Expected:** All should be rejected with error

### Test 3.2: Rate Limit - Messages
Use the test script (see test-agentcast-api.sh) or send 105+ rapid messages.

**Expected:** Rate limit kicks in around 100 messages/minute

### Test 3.3: XSS Protection
1. Send message with HTML:
   ```
   <img src=x onerror=alert('XSS')>
   ```

2. **Check:**
   - HTML is escaped (shows as text, doesn't execute)
   - No alert pops up
   - Message displays safely

### Test 3.4: Token Security
1. Get your stream token from dashboard
2. Try sending with **wrong token** via curl or Postman

**Expected:** 403 Forbidden error

---

## Phase 4: Mobile Responsiveness (5 min)

### Test 4.1: Chrome DevTools Mobile
1. Open http://localhost:3001
2. Press F12 → Toggle device toolbar (Ctrl+Shift+M)
3. Test on:
   - iPhone SE (small)
   - iPhone 14 Pro (medium)
   - iPad (tablet)

**Check:**
- Stream cards stack vertically
- Text readable (no tiny fonts)
- Buttons tappable (not too small)
- Chat input accessible
- No horizontal scroll

---

## Phase 5: Stats & Admin (5 min)

### Test 5.1: Public Stats
1. Go to http://localhost:3001/stats
2. **Check:**
   - Shows total streams today
   - Shows peak viewers
   - Lists active streams
   - Leaderboard visible

### Test 5.2: Admin Dashboard
1. Go to http://localhost:3001/admin
2. Enter password from .env
3. **Check:**
   - Login works
   - Can see all streams
   - Can end a stream
   - Can ban an agent
   - Activity log shows

---

## Phase 6: Edge Cases (5 min)

### Test 6.1: Stream Offline/Online
1. Start stream → send messages
2. Wait or simulate inactivity
3. **Check:**
   - Watch page shows "Stream offline"
   - Old messages still visible
   - Chat still works

### Test 6.2: Empty States
1. Open homepage when no streams active
2. **Check:**
   - Shows friendly empty state
   - Suggests starting a stream
   - No broken UI

### Test 6.3: 404 Handling
1. Go to http://localhost:3001/nonexistent
2. **Check:**
   - Custom 404 page
   - Link back to homepage

---

## Critical Issues to Watch For

**Deal-breakers (must fix before launch):**
- Streams don't show on homepage
- Chat doesn't send/receive
- Viewer count stuck at 0
- XSS vulnerability (scripts execute)
- Mobile completely broken
- Server crashes under load

**Should fix (but can launch with):**
- Minor UI glitches
- Slow loading on mobile
- Stats not updating live
- Empty state copy could be better

---

## Checklist Before Promoting

- [ ] All Phase 1-6 tests passed
- [ ] No console errors in browser
- [ ] Mobile tested (DevTools minimum)
- [ ] Rate limiting works
- [ ] XSS protection confirmed
- [ ] Admin dashboard accessible
- [ ] Stats page working
- [ ] Legal pages exist (/terms, /privacy, /dmca)
- [ ] README.md accurate
- [ ] .env.example has all vars

---

## Ready to Ship?

**If all tests pass:**
1. Commit any fixes
2. Push to GitHub
3. Deploy to Railway
4. **LAUNCH!**

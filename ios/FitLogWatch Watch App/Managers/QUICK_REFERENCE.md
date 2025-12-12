# ConnectivityManager Quick Reference

## Key Validation Functions

```swift
// Before ANY WatchConnectivity operation
if !isSessionReady() {
    // Session not ready - message will be queued
}

// Before immediate delivery
if canSendImmediate() {
    // Session ready AND reachable - send now
}
```

## Message Sending Patterns

### Critical Messages (Must Deliver)
```swift
sendToiPhone(data, critical: true, forceImmediate: true)
```
Uses: Set completion, workout end, modifications

### Non-Critical Messages (Best Effort)
```swift
sendToiPhone(data, critical: false, forceImmediate: true)
```
Uses: Skip rest, health metrics updates

### Rate-Limited Messages (Throttled)
```swift
sendToiPhone(data, critical: false, forceImmediate: false)
```
Uses: Continuous health metrics, non-urgent updates

## Debug Log Indicators

| Icon | Meaning |
|------|---------|
| ✅ | Success - operation completed |
| ⚠️ | Warning - fallback or rate limit |
| ❌ | Error - operation failed |
| 🔄 | Processing - retry or queue operation |
| 📊 | Status - connection state info |
| 📥 | Queue - message queued |
| 📤 | Send - message being sent |
| 🧹 | Cleanup - state cleared |

## Common Scenarios

### Message Not Sending?
1. Check logs for "WCSession not ready"
2. Verify `isActivated == true`
3. Check `isPaired` and `isWatchAppInstalled`
4. Message will be queued automatically

### Messages Being Queued?
1. Normal if iPhone not reachable
2. Queue max 20 messages
3. Auto-processed when connection restored
4. Check queue size in logs

### Excessive Retries?
1. Max 3 retries per message type
2. Exponential backoff (2s, 4s, 8s)
3. After max retries, message dropped
4. Check error codes in logs

## Error Codes Reference

| Code | Issue | Action |
|------|-------|--------|
| 7003 | Not reachable | Queued for retry |
| 7004 | Payload too large | Log warning |
| 7005 | Session not activated | Reconnection attempt |
| 7007 | File not found | Log error |
| 7009 | Insufficient space | Log warning |

## Monitoring Connection Health

Watch logs for:
```
✅ WCSession activated successfully
📊 isPaired: true, isWatchAppInstalled: true
🔄 Reachability changed: false → true
⏱️ Time since last change: 5.2s
```

## Queue Status

Check logs for queue size:
```
📥 Queued message: setCompleted (queue size: 1)
🔄 Processing 3 pending messages
```

## Best Practices

1. **Always validate** with `isSessionReady()` or `canSendImmediate()`
2. **Mark critical messages** appropriately
3. **Monitor logs** for patterns in connection issues
4. **Don't disable rate limiting** unless necessary
5. **Trust the queue** - messages will be delivered

---

For detailed documentation, see `CONNECTIVITY_IMPROVEMENTS.md`

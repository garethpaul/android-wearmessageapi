package garethpaul.com.wearer;

public final class MessageDeliveryRateLimiterHostTest {
    private int cases;

    public static void main(String[] args) {
        MessageDeliveryRateLimiterHostTest test = new MessageDeliveryRateLimiterHostTest();
        test.run();
        System.out.println("Wear delivery rate limiter tests passed: " + test.cases + " cases.");
    }

    private void run() {
        acceptsFirstDeliveryAndCooldownBoundary();
        rejectedDeliveryDoesNotMoveWindow();
        keepsSourceWindowsIndependent();
        rejectsInvalidSourceAndTime();
        rejectsBackwardTimeWithoutCorruptingState();
        exactRollbackPermitsRetry();
        staleRollbackCannotClearNewerReservation();
        evictsOldestSourceAtCapacity();
    }

    private void acceptsFirstDeliveryAndCooldownBoundary() {
        MessageDeliveryRateLimiter limiter = limiter(3, 200L);
        expectTrue(limiter.allow("node-a", 1000L));
        expectFalse(limiter.allow("node-a", 1199L));
        expectTrue(limiter.allow("node-a", 1200L));
        cases++;
    }

    private void rejectedDeliveryDoesNotMoveWindow() {
        MessageDeliveryRateLimiter limiter = limiter(3, 200L);
        expectTrue(limiter.allow("node-a", 1000L));
        expectFalse(limiter.allow("node-a", 1100L));
        expectTrue(limiter.allow("node-a", 1200L));
        cases++;
    }

    private void keepsSourceWindowsIndependent() {
        MessageDeliveryRateLimiter limiter = limiter(3, 200L);
        expectTrue(limiter.allow("node-a", 1000L));
        expectTrue(limiter.allow("node-b", 1001L));
        expectFalse(limiter.allow("node-a", 1001L));
        cases++;
    }

    private void rejectsInvalidSourceAndTime() {
        MessageDeliveryRateLimiter limiter = limiter(3, 200L);
        expectFalse(limiter.allow(null, 1000L));
        expectFalse(limiter.allow("   ", 1000L));
        expectFalse(limiter.allow("node-a", -1L));
        expectTrue(limiter.allow("node-a", 0L));
        cases++;
    }

    private void rejectsBackwardTimeWithoutCorruptingState() {
        MessageDeliveryRateLimiter limiter = limiter(3, 200L);
        expectTrue(limiter.allow("node-a", 1000L));
        expectFalse(limiter.allow("node-a", 999L));
        expectTrue(limiter.allow("node-a", 1200L));
        cases++;
    }

    private void exactRollbackPermitsRetry() {
        MessageDeliveryRateLimiter limiter = limiter(3, 200L);
        expectTrue(limiter.allow("node-a", 1000L));
        expectTrue(limiter.forget("node-a", 1000L));
        expectTrue(limiter.allow("node-a", 1000L));
        cases++;
    }

    private void staleRollbackCannotClearNewerReservation() {
        MessageDeliveryRateLimiter limiter = limiter(3, 200L);
        expectTrue(limiter.allow("node-a", 1000L));
        expectTrue(limiter.allow("node-a", 1200L));
        expectFalse(limiter.forget("node-a", 1000L));
        expectFalse(limiter.allow("node-a", 1399L));
        expectTrue(limiter.allow("node-a", 1400L));
        cases++;
    }

    private void evictsOldestSourceAtCapacity() {
        MessageDeliveryRateLimiter limiter = limiter(2, 200L);
        expectTrue(limiter.allow("node-a", 1000L));
        expectTrue(limiter.allow("node-b", 1000L));
        expectTrue(limiter.allow("node-c", 1000L));
        expectTrue(limiter.allow("node-a", 1001L));
        cases++;
    }

    private static MessageDeliveryRateLimiter limiter(int maxSources, long intervalMillis) {
        return new MessageDeliveryRateLimiter(maxSources, intervalMillis);
    }

    private static void expectTrue(boolean value) {
        if (!value) {
            throw new AssertionError("Expected true");
        }
    }

    private static void expectFalse(boolean value) {
        if (value) {
            throw new AssertionError("Expected false");
        }
    }
}

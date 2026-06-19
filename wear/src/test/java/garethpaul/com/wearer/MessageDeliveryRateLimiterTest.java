package garethpaul.com.wearer;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class MessageDeliveryRateLimiterTest {
    @Test
    public void enforcesPerSourceCooldownWithoutMovingRejectedWindow() {
        MessageDeliveryRateLimiter limiter = new MessageDeliveryRateLimiter(3, 200L);

        assertTrue(limiter.allow("node-a", 1000L));
        assertFalse(limiter.allow("node-a", 1100L));
        assertTrue(limiter.allow("node-b", 1100L));
        assertTrue(limiter.allow("node-a", 1200L));
    }

    @Test
    public void rejectsInvalidAndBackwardTimeWithoutCorruptingState() {
        MessageDeliveryRateLimiter limiter = new MessageDeliveryRateLimiter(3, 200L);

        assertFalse(limiter.allow(null, 1000L));
        assertFalse(limiter.allow(" ", 1000L));
        assertFalse(limiter.allow("node-a", -1L));
        assertTrue(limiter.allow("node-a", 1000L));
        assertFalse(limiter.allow("node-a", 999L));
        assertTrue(limiter.allow("node-a", 1200L));
    }

    @Test
    public void exactRollbackCannotClearNewerReservation() {
        MessageDeliveryRateLimiter limiter = new MessageDeliveryRateLimiter(3, 200L);

        assertTrue(limiter.allow("node-a", 1000L));
        assertTrue(limiter.allow("node-a", 1200L));
        assertFalse(limiter.forget("node-a", 1000L));
        assertFalse(limiter.allow("node-a", 1399L));
        assertTrue(limiter.forget("node-a", 1200L));
        assertTrue(limiter.allow("node-a", 1200L));
    }

    @Test
    public void evictsOldestSourceAtCapacity() {
        MessageDeliveryRateLimiter limiter = new MessageDeliveryRateLimiter(2, 200L);

        assertTrue(limiter.allow("node-a", 1000L));
        assertTrue(limiter.allow("node-b", 1000L));
        assertTrue(limiter.allow("node-c", 1000L));
        assertTrue(limiter.allow("node-a", 1001L));
    }
}

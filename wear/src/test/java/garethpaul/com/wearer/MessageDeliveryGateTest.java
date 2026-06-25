package garethpaul.com.wearer;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

public class MessageDeliveryGateTest {
    @Test
    public void canonicalPathsUseSeparateCooldownLanes() {
        MessageDeliveryGate gate = gate();

        assertNotNull(gate.reserve("node-a", WearMessage.START_ACTIVITY, 1, 1000L));
        assertNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 2, 1001L));
    }

    @Test
    public void sameCanonicalPathRemainsRateLimited() {
        MessageDeliveryGate gate = gate();

        assertNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L));
        assertNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 2, 1001L));
    }

    @Test
    public void replayIdentityRemainsIndependentOfPath() {
        MessageDeliveryGate gate = gate();
        MessageDeliveryGate.Reservation first = gate.reserve(
                "node-a", WearMessage.START_ACTIVITY, 1, 1000L);

        assertNotNull(first);
        assertTrue(gate.commit(first));
        assertNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1500L));
    }

    @Test
    public void rateLimitedRequestRemainsRetryableAfterCooldown() {
        MessageDeliveryGate gate = gate();
        MessageDeliveryGate.Reservation first = gate.reserve(
                "node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L);

        assertNotNull(first);
        assertTrue(gate.commit(first));
        assertNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 2, 1001L));
        assertNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 2, 1500L));
    }

    @Test
    public void duplicateRequestDoesNotConsumeCooldown() {
        MessageDeliveryGate gate = gate();
        MessageDeliveryGate.Reservation first = gate.reserve(
                "node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L);

        assertNotNull(first);
        assertTrue(gate.commit(first));
        assertNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1500L));
        assertNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 2, 1500L));
    }

    @Test
    public void staleLaunchFailureCannotReleaseNewReservation() {
        MessageDeliveryGate gate = gate();
        MessageDeliveryGate.Reservation first = gate.reserve(
                "node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L);

        assertNotNull(first);
        assertTrue(gate.release(first));
        assertNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L));
        assertFalse(gate.release(first));
    }

    @Test
    public void pendingRequestSurvivesReplayCacheEviction() {
        MessageDeliveryGate gate = new MessageDeliveryGate(1, 100, 500L);

        assertNotNull(gate.reserve("node-a", WearMessage.START_ACTIVITY, 1, 1000L));
        assertNotNull(gate.reserve("node-b", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L));
        assertNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1500L));
    }

    private static MessageDeliveryGate gate() {
        return new MessageDeliveryGate(100, 100, 500L);
    }
}

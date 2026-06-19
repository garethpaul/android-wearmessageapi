package garethpaul.com.wearer;

public final class MessageDeliveryGateHostTest {
    private static int cases;

    public static void main(String[] args) {
        rateLimitedRequestRemainsRetryable();
        duplicateRequestDoesNotConsumeCooldown();
        launchFailureReleasesExactReservation();
        pendingRequestSurvivesReplayCacheEviction();

        if (cases != 4) {
            throw new AssertionError("Expected 4 cases, ran " + cases);
        }
        System.out.println("Message delivery gate tests passed: " + cases + " cases.");
    }

    private static void rateLimitedRequestRemainsRetryable() {
        MessageDeliveryGate gate = gate();
        MessageDeliveryGate.Reservation first = gate.reserve("node-a", 1, 1000L);
        expectNotNull(first);
        expectTrue(gate.commit(first));
        expectNull(gate.reserve("node-a", 2, 1001L));
        expectNotNull(gate.reserve("node-a", 2, 1500L));
        cases++;
    }

    private static void duplicateRequestDoesNotConsumeCooldown() {
        MessageDeliveryGate gate = gate();
        MessageDeliveryGate.Reservation first = gate.reserve("node-a", 1, 1000L);
        expectNotNull(first);
        expectTrue(gate.commit(first));
        expectNull(gate.reserve("node-a", 1, 1500L));
        expectNotNull(gate.reserve("node-a", 2, 1500L));
        cases++;
    }

    private static void launchFailureReleasesExactReservation() {
        MessageDeliveryGate gate = gate();
        MessageDeliveryGate.Reservation first = gate.reserve("node-a", 1, 1000L);
        expectNotNull(first);
        expectTrue(gate.release(first));
        expectNotNull(gate.reserve("node-a", 1, 1000L));
        expectFalse(gate.release(first));
        cases++;
    }

    private static void pendingRequestSurvivesReplayCacheEviction() {
        MessageDeliveryGate gate = new MessageDeliveryGate(1, 100, 500L);
        expectNotNull(gate.reserve("node-a", 1, 1000L));
        expectNotNull(gate.reserve("node-b", 1, 1000L));
        expectNull(gate.reserve("node-a", 1, 1500L));
        cases++;
    }

    private static MessageDeliveryGate gate() {
        return new MessageDeliveryGate(100, 100, 500L);
    }

    private static void expectNotNull(Object value) {
        if (value == null) {
            throw new AssertionError("Expected non-null value");
        }
    }

    private static void expectNull(Object value) {
        if (value != null) {
            throw new AssertionError("Expected null value");
        }
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

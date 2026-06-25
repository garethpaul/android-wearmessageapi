package garethpaul.com.wearer;

public final class MessageDeliveryGateHostTest {
    private static int cases;

    public static void main(String[] args) {
        startThenMessageUsesSeparateCooldownLanes();
        messageThenStartUsesSeparateCooldownLanes();
        repeatedStartActivityIsRateLimited();
        repeatedMessageIsRateLimited();
        replayIdentitySpansCanonicalPaths();
        cooldownLanesRemainSourceIsolated();
        rateLimitedRequestRemainsRetryable();
        duplicateRequestDoesNotConsumeCooldown();
        launchFailureReleasesExactReservation();
        releaseDoesNotClearOtherPathLane();
        pendingRequestSurvivesReplayCacheEviction();
        cooldownCacheRemainsBoundedAcrossPathLanes();
        nonCanonicalPathsDoNotMutateAdmissionState();

        if (cases != 13) {
            throw new AssertionError("Expected 13 cases, ran " + cases);
        }
        System.out.println("Message delivery gate tests passed: " + cases + " cases.");
    }

    private static void startThenMessageUsesSeparateCooldownLanes() {
        MessageDeliveryGate gate = gate();
        expectNotNull(gate.reserve("node-a", WearMessage.START_ACTIVITY, 1, 1000L));
        expectNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 2, 1001L));
        cases++;
    }

    private static void messageThenStartUsesSeparateCooldownLanes() {
        MessageDeliveryGate gate = gate();
        expectNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L));
        expectNotNull(gate.reserve("node-a", WearMessage.START_ACTIVITY, 2, 1001L));
        cases++;
    }

    private static void repeatedStartActivityIsRateLimited() {
        MessageDeliveryGate gate = gate();
        expectNotNull(gate.reserve("node-a", WearMessage.START_ACTIVITY, 1, 1000L));
        expectNull(gate.reserve("node-a", WearMessage.START_ACTIVITY, 2, 1001L));
        cases++;
    }

    private static void repeatedMessageIsRateLimited() {
        MessageDeliveryGate gate = gate();
        expectNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L));
        expectNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 2, 1001L));
        cases++;
    }

    private static void replayIdentitySpansCanonicalPaths() {
        MessageDeliveryGate gate = gate();
        MessageDeliveryGate.Reservation first = gate.reserve(
                "node-a", WearMessage.START_ACTIVITY, 1, 1000L);
        expectNotNull(first);
        expectTrue(gate.commit(first));
        expectNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1500L));
        cases++;
    }

    private static void cooldownLanesRemainSourceIsolated() {
        MessageDeliveryGate gate = gate();
        expectNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L));
        expectNotNull(gate.reserve("node-b", WearMessage.WEAR_MESSAGE_PATH, 1, 1001L));
        cases++;
    }

    private static void rateLimitedRequestRemainsRetryable() {
        MessageDeliveryGate gate = gate();
        MessageDeliveryGate.Reservation first = gate.reserve(
                "node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L);
        expectNotNull(first);
        expectTrue(gate.commit(first));
        expectNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 2, 1001L));
        expectNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 2, 1500L));
        cases++;
    }

    private static void duplicateRequestDoesNotConsumeCooldown() {
        MessageDeliveryGate gate = gate();
        MessageDeliveryGate.Reservation first = gate.reserve(
                "node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L);
        expectNotNull(first);
        expectTrue(gate.commit(first));
        expectNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1500L));
        expectNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 2, 1500L));
        cases++;
    }

    private static void launchFailureReleasesExactReservation() {
        MessageDeliveryGate gate = gate();
        MessageDeliveryGate.Reservation first = gate.reserve(
                "node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L);
        expectNotNull(first);
        expectTrue(gate.release(first));
        expectNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L));
        expectFalse(gate.release(first));
        cases++;
    }

    private static void releaseDoesNotClearOtherPathLane() {
        MessageDeliveryGate gate = gate();
        MessageDeliveryGate.Reservation start = gate.reserve(
                "node-a", WearMessage.START_ACTIVITY, 1, 1000L);
        MessageDeliveryGate.Reservation message = gate.reserve(
                "node-a", WearMessage.WEAR_MESSAGE_PATH, 2, 1001L);
        expectNotNull(start);
        expectNotNull(message);
        expectTrue(gate.release(start));
        expectNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 3, 1002L));
        expectNotNull(gate.reserve("node-a", WearMessage.START_ACTIVITY, 1, 1000L));
        cases++;
    }

    private static void pendingRequestSurvivesReplayCacheEviction() {
        MessageDeliveryGate gate = new MessageDeliveryGate(1, 100, 500L);
        expectNotNull(gate.reserve("node-a", WearMessage.START_ACTIVITY, 1, 1000L));
        expectNotNull(gate.reserve("node-b", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L));
        expectNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1500L));
        cases++;
    }

    private static void cooldownCacheRemainsBoundedAcrossPathLanes() {
        MessageDeliveryGate gate = new MessageDeliveryGate(100, 1, 500L);
        MessageDeliveryGate.Reservation first = gate.reserve(
                "node-a", WearMessage.START_ACTIVITY, 1, 1000L);
        MessageDeliveryGate.Reservation second = gate.reserve(
                "node-a", WearMessage.WEAR_MESSAGE_PATH, 2, 1001L);
        expectNotNull(first);
        expectNotNull(second);
        expectTrue(gate.commit(first));
        expectTrue(gate.commit(second));
        expectNotNull(gate.reserve("node-a", WearMessage.START_ACTIVITY, 3, 1002L));
        cases++;
    }

    private static void nonCanonicalPathsDoNotMutateAdmissionState() {
        MessageDeliveryGate gate = gate();
        expectNull(gate.reserve("node-a", "/MESSAGE", 1, 1000L));
        expectNull(gate.reserve("node-a", " /message", 1, 1000L));
        expectNull(gate.reserve("node-a", null, 1, 1000L));
        expectNotNull(gate.reserve("node-a", WearMessage.WEAR_MESSAGE_PATH, 1, 1000L));
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

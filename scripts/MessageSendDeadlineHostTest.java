package garethpaul.com.wearer;

public final class MessageSendDeadlineHostTest {
    private int cases;

    public static void main(String[] args) {
        MessageSendDeadlineHostTest test = new MessageSendDeadlineHostTest();
        test.run();
        System.out.println("Wear message send deadline tests passed: "
                + test.cases + " cases.");
    }

    private void run() {
        preservesFullBudgetAtStart();
        subtractsElapsedTimeFromSharedBudget();
        expiresAtAndBeyondDeadline();
        rejectsNonPositiveTimeouts();
    }

    private void preservesFullBudgetAtStart() {
        expectEquals(5000L, MessageSendDeadline.remainingNanos(100L, 100L, 5000L));
        cases++;
    }

    private void subtractsElapsedTimeFromSharedBudget() {
        expectEquals(3500L, MessageSendDeadline.remainingNanos(100L, 1600L, 5000L));
        cases++;
    }

    private void expiresAtAndBeyondDeadline() {
        expectEquals(0L, MessageSendDeadline.remainingNanos(100L, 5100L, 5000L));
        expectEquals(0L, MessageSendDeadline.remainingNanos(100L, 6000L, 5000L));
        cases++;
    }

    private void rejectsNonPositiveTimeouts() {
        expectEquals(0L, MessageSendDeadline.remainingNanos(100L, 100L, 0L));
        expectEquals(0L, MessageSendDeadline.remainingNanos(100L, 100L, -1L));
        cases++;
    }

    private static void expectEquals(long expected, long actual) {
        if (expected != actual) {
            throw new AssertionError("Expected " + expected + " but was " + actual);
        }
    }
}

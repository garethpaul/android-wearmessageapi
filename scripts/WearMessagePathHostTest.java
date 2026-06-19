package garethpaul.com.wearer;

public final class WearMessagePathHostTest {
    private static int cases;

    public static void main(String[] args) {
        expectTrue(WearMessage.isStartActivityPath("/start_activity"));
        expectFalse(WearMessage.isStartActivityPath("/START_ACTIVITY"));
        expectFalse(WearMessage.isStartActivityPath("/start_activity/"));
        expectFalse(WearMessage.isStartActivityPath(null));

        expectTrue(WearMessage.isWearMessagePath("/message"));
        expectFalse(WearMessage.isWearMessagePath("/MESSAGE"));
        expectFalse(WearMessage.isWearMessagePath("/message/"));
        expectFalse(WearMessage.isWearMessagePath(null));

        if (cases != 8) {
            throw new AssertionError("Expected 8 cases, ran " + cases);
        }
        System.out.println("Canonical Wear message path tests passed: " + cases + " cases.");
    }

    private static void expectTrue(boolean value) {
        if (!value) {
            throw new AssertionError("Expected true");
        }
        cases++;
    }

    private static void expectFalse(boolean value) {
        if (value) {
            throw new AssertionError("Expected false");
        }
        cases++;
    }
}

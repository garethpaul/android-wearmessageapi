package garethpaul.com.wearer;

final class MessageSendDeadline {
    private MessageSendDeadline() {
    }

    static long remainingNanos(long startedAtNanos, long currentNanos, long timeoutNanos) {
        if (timeoutNanos <= 0L) {
            return 0L;
        }

        long elapsedNanos = currentNanos - startedAtNanos;
        if (elapsedNanos <= 0L) {
            return timeoutNanos;
        }
        if (elapsedNanos >= timeoutNanos) {
            return 0L;
        }
        return timeoutNanos - elapsedNanos;
    }
}

package garethpaul.com.wearer;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.CodingErrorAction;
import java.util.Iterator;
import java.util.LinkedHashSet;

final class WearMessage {
    static final String START_ACTIVITY = "/start_activity";
    static final String WEAR_MESSAGE_PATH = "/message";
    static final String EXTRA_MESSAGE = "garethpaul.com.wearer.MESSAGE";
    static final int MAX_MESSAGE_BYTES = 4096;
    static final int MAX_HISTORY_ENTRIES = 100;
    static final int MAX_RECENT_MESSAGE_IDS = 100;
    private static final Charset MESSAGE_CHARSET = Charset.forName("UTF-8");

    private WearMessage() {
    }

    static byte[] encode(String text) {
        if (text == null) {
            return new byte[0];
        }
        return text.getBytes(MESSAGE_CHARSET);
    }

    static String decode(byte[] data) {
        if (data == null) {
            return "";
        }
        return new String(data, MESSAGE_CHARSET);
    }

    static String normalizeText(CharSequence text) {
        if (text == null) {
            return "";
        }
        return text.toString().trim();
    }

    static boolean isValidMessageText(String text) {
        String normalizedText = normalizeText(text);
        return normalizedText.length() > 0
                && encode(normalizedText).length <= MAX_MESSAGE_BYTES;
    }

    static boolean isValidPayload(byte[] data) {
        return decodeValidPayload(data) != null;
    }

    static String decodeValidPayload(byte[] data) {
        if (data == null || data.length == 0 || data.length > MAX_MESSAGE_BYTES) {
            return null;
        }

        try {
            return MESSAGE_CHARSET.newDecoder()
                    .onMalformedInput(CodingErrorAction.REPORT)
                    .onUnmappableCharacter(CodingErrorAction.REPORT)
                    .decode(ByteBuffer.wrap(data))
                    .toString();
        } catch (CharacterCodingException exception) {
            return null;
        }
    }

    static boolean shouldClearInput(CharSequence currentText, String sentText) {
        String normalizedSentText = normalizeText(sentText);
        return normalizedSentText.length() > 0
                && normalizedSentText.equals(normalizeText(currentText));
    }

    static boolean shouldRemoveOldestHistoryEntry(int currentEntryCount) {
        return currentEntryCount >= MAX_HISTORY_ENTRIES;
    }

    static boolean isStartActivityPath(String path) {
        return path != null && START_ACTIVITY.equalsIgnoreCase(path);
    }

    static boolean isWearMessagePath(String path) {
        return path != null && WEAR_MESSAGE_PATH.equalsIgnoreCase(path);
    }

    static final class RecentMessageIds {
        private final int maxEntries;
        private final LinkedHashSet<String> identities = new LinkedHashSet<String>();

        RecentMessageIds(int maxEntries) {
            if (maxEntries <= 0) {
                throw new IllegalArgumentException("maxEntries must be positive");
            }
            this.maxEntries = maxEntries;
        }

        synchronized boolean record(String sourceNodeId, int requestId) {
            String normalizedSourceNodeId = normalizeText(sourceNodeId);
            if (normalizedSourceNodeId.length() == 0) {
                return false;
            }

            String identity = normalizedSourceNodeId + "\n" + requestId;
            if (!identities.add(identity)) {
                return false;
            }

            while (identities.size() > maxEntries) {
                Iterator<String> iterator = identities.iterator();
                iterator.next();
                iterator.remove();
            }
            return true;
        }
    }
}

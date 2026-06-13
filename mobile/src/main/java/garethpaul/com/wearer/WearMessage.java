package garethpaul.com.wearer;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.CodingErrorAction;

final class WearMessage {
    static final String START_ACTIVITY = "/start_activity";
    static final String WEAR_MESSAGE_PATH = "/message";
    static final int MAX_MESSAGE_BYTES = 4096;
    static final int MAX_HISTORY_ENTRIES = 100;
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
        if (data == null || data.length == 0 || data.length > MAX_MESSAGE_BYTES) {
            return false;
        }

        try {
            MESSAGE_CHARSET.newDecoder()
                    .onMalformedInput(CodingErrorAction.REPORT)
                    .onUnmappableCharacter(CodingErrorAction.REPORT)
                    .decode(ByteBuffer.wrap(data));
            return true;
        } catch (CharacterCodingException exception) {
            return false;
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
}

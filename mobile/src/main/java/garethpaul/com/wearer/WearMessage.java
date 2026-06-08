package garethpaul.com.wearer;

import java.nio.charset.Charset;

final class WearMessage {
    static final String START_ACTIVITY = "/start_activity";
    static final String WEAR_MESSAGE_PATH = "/message";
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

    static boolean isStartActivityPath(String path) {
        return path != null && START_ACTIVITY.equalsIgnoreCase(path);
    }

    static boolean isWearMessagePath(String path) {
        return path != null && WEAR_MESSAGE_PATH.equalsIgnoreCase(path);
    }
}

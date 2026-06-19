package garethpaul.com.wearer;

import org.junit.Test;

import java.nio.charset.Charset;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

public class WearMessageTest {
    private static final Charset UTF_8 = Charset.forName("UTF-8");

    @Test
    public void recognizesOnlyCanonicalStartActivityPath() {
        assertTrue(WearMessage.isStartActivityPath("/start_activity"));
        assertFalse(WearMessage.isStartActivityPath("/START_ACTIVITY"));
        assertFalse(WearMessage.isStartActivityPath("/message"));
        assertFalse(WearMessage.isStartActivityPath(null));
    }

    @Test
    public void recognizesOnlyCanonicalWearMessagePath() {
        assertTrue(WearMessage.isWearMessagePath("/message"));
        assertFalse(WearMessage.isWearMessagePath("/MESSAGE"));
        assertFalse(WearMessage.isWearMessagePath("/start_activity"));
        assertFalse(WearMessage.isWearMessagePath(null));
    }

    @Test
    public void encodesMessagesAsUtf8() {
        String text = "Cafe \u2603";

        assertEquals(text, WearMessage.decode(WearMessage.encode(text)));
    }

    @Test
    public void encodesNullTextAsEmptyPayload() {
        assertEquals(0, WearMessage.encode(null).length);
    }

    @Test
    public void decodesNullPayloadAsEmptyText() {
        assertEquals("", WearMessage.decode(null));
    }

    @Test
    public void normalizesBlankMessageTextAsEmpty() {
        assertEquals("", WearMessage.normalizeText(null));
        assertEquals("", WearMessage.normalizeText("   "));
        assertEquals("hello", WearMessage.normalizeText(" hello "));
    }

    @Test
    public void acceptsOnlyBoundedNonBlankMessages() {
        assertTrue(WearMessage.isValidMessageText("hello"));
        assertTrue(WearMessage.isValidMessageText(repeat('x', WearMessage.MAX_MESSAGE_BYTES)));
        assertTrue(WearMessage.isValidMessageText(repeat('\u00e9', WearMessage.MAX_MESSAGE_BYTES / 2)));
        assertFalse(WearMessage.isValidMessageText("   "));
        assertFalse(WearMessage.isValidMessageText(repeat('x', WearMessage.MAX_MESSAGE_BYTES + 1)));
        assertFalse(WearMessage.isValidMessageText(repeat('\u00e9', WearMessage.MAX_MESSAGE_BYTES / 2 + 1)));
    }

    @Test
    public void acceptsOnlyBoundedStrictUtf8Payloads() {
        assertTrue(WearMessage.isValidPayload(new byte[] { 1 }));
        assertTrue(WearMessage.isValidPayload("\u2603".getBytes(UTF_8)));
        assertTrue(WearMessage.isValidPayload(new byte[WearMessage.MAX_MESSAGE_BYTES]));
        assertFalse(WearMessage.isValidPayload(null));
        assertFalse(WearMessage.isValidPayload(new byte[0]));
        assertFalse(WearMessage.isValidPayload(new byte[] { (byte) 0xe2, (byte) 0x82 }));
        assertFalse(WearMessage.isValidPayload(new byte[] { (byte) 0x80 }));
        assertFalse(WearMessage.isValidPayload(new byte[WearMessage.MAX_MESSAGE_BYTES + 1]));
    }

    @Test
    public void decodesOnlyBoundedStrictUtf8Payloads() {
        assertEquals("hello", WearMessage.decodeValidPayload("hello".getBytes(UTF_8)));
        assertEquals(WearMessage.MAX_MESSAGE_BYTES,
                WearMessage.decodeValidPayload(
                        new byte[WearMessage.MAX_MESSAGE_BYTES]).length());
        assertNull(WearMessage.decodeValidPayload(null));
        assertNull(WearMessage.decodeValidPayload(new byte[0]));
        assertNull(WearMessage.decodeValidPayload(
                new byte[] { (byte) 0xe2, (byte) 0x82 }));
        assertNull(WearMessage.decodeValidPayload(
                new byte[WearMessage.MAX_MESSAGE_BYTES + 1]));
    }

    private static String repeat(char value, int count) {
        StringBuilder result = new StringBuilder(count);
        for (int index = 0; index < count; index++) {
            result.append(value);
        }
        return result.toString();
    }

    @Test
    public void clearsOnlyMatchingCurrentInput() {
        assertTrue(WearMessage.shouldClearInput(" hello ", "hello"));
        assertFalse(WearMessage.shouldClearInput("new text", "hello"));
        assertFalse(WearMessage.shouldClearInput(null, "hello"));
        assertFalse(WearMessage.shouldClearInput("", ""));
    }

    @Test
    public void removesOldestEntryAtHistoryLimit() {
        assertFalse(WearMessage.shouldRemoveOldestHistoryEntry(
                WearMessage.MAX_HISTORY_ENTRIES - 1));
        assertTrue(WearMessage.shouldRemoveOldestHistoryEntry(
                WearMessage.MAX_HISTORY_ENTRIES));
        assertTrue(WearMessage.shouldRemoveOldestHistoryEntry(
                WearMessage.MAX_HISTORY_ENTRIES + 1));
    }
}

package garethpaul.com.wearer;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class WearMessageTest {

    @Test
    public void recognizesStartActivityPathCaseInsensitively() {
        assertTrue(WearMessage.isStartActivityPath("/START_ACTIVITY"));
        assertFalse(WearMessage.isStartActivityPath("/message"));
        assertFalse(WearMessage.isStartActivityPath(null));
    }

    @Test
    public void recognizesWearMessagePathCaseInsensitively() {
        assertTrue(WearMessage.isWearMessagePath("/MESSAGE"));
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
}

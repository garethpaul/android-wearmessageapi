package garethpaul.com.wearer;

/**
 * Created by gareth on 5/7/15.
 */


import android.content.ActivityNotFoundException;
import android.content.Intent;

import com.google.android.gms.wearable.MessageEvent;
import com.google.android.gms.wearable.WearableListenerService;

public class WearMessageListenerService extends WearableListenerService {
    private final WearMessage.RecentMessageIds recentMessageIds =
            new WearMessage.RecentMessageIds(WearMessage.MAX_RECENT_MESSAGE_IDS);

    @Override
    public void onMessageReceived(MessageEvent messageEvent) {
        if( messageEvent == null ) {
            return;
        }

        if( WearMessage.isStartActivityPath(messageEvent.getPath()) ) {
            deliverOnce(messageEvent, null);
        } else if (WearMessage.isWearMessagePath(messageEvent.getPath())) {
            byte[] payload = messageEvent.getData();
            String message = WearMessage.decodeValidPayload(payload);
            boolean validMessage = WearMessage.isValidMessageText(message);
            if (validMessage) {
                deliverOnce(messageEvent, message);
            } else if (!validMessage) {
                super.onMessageReceived(messageEvent);
            }
        } else {
            super.onMessageReceived(messageEvent);
        }
    }

    private void deliverOnce(MessageEvent messageEvent, String message) {
        String sourceNodeId = messageEvent.getSourceNodeId();
        int requestId = messageEvent.getRequestId();
        if (!recentMessageIds.record(sourceNodeId, requestId)) {
            return;
        }

        if (!startWearActivity(message)) {
            recentMessageIds.forget(sourceNodeId, requestId);
        }
    }

    private boolean startWearActivity(String message) {
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK
                | Intent.FLAG_ACTIVITY_CLEAR_TOP
                | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        if (message != null) {
            intent.putExtra(WearMessage.EXTRA_MESSAGE, message);
        }
        try {
            startActivity(intent);
            return true;
        } catch (ActivityNotFoundException ignored) {
            return false;
        } catch (SecurityException ignored) {
            return false;
        }
    }

}

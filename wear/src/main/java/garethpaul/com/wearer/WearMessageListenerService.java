package garethpaul.com.wearer;

/**
 * Created by gareth on 5/7/15.
 */


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
            if (recentMessageIds.record(
                    messageEvent.getSourceNodeId(), messageEvent.getRequestId())) {
                startWearActivity(null);
            }
        } else if (WearMessage.isWearMessagePath(messageEvent.getPath())) {
            byte[] payload = messageEvent.getData();
            String message = WearMessage.decodeValidPayload(payload);
            if (message != null && recentMessageIds.record(
                    messageEvent.getSourceNodeId(), messageEvent.getRequestId())) {
                startWearActivity(message);
            } else if (message == null) {
                super.onMessageReceived(messageEvent);
            }
        } else {
            super.onMessageReceived(messageEvent);
        }
    }

    private void startWearActivity(String message) {
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK
                | Intent.FLAG_ACTIVITY_CLEAR_TOP
                | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        if (message != null) {
            intent.putExtra(WearMessage.EXTRA_MESSAGE, message);
        }
        startActivity(intent);
    }

}

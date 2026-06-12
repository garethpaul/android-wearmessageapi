package garethpaul.com.wearer;


import android.app.Activity;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.wearable.MessageApi;
import com.google.android.gms.wearable.Node;
import com.google.android.gms.wearable.NodeApi;
import com.google.android.gms.wearable.Wearable;

import java.util.concurrent.TimeUnit;


public class MainActivity extends Activity implements GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener {

    private static final long MESSAGE_OPERATION_TIMEOUT_SECONDS = 5L;

    private GoogleApiClient mApiClient;

    private ArrayAdapter<String> mAdapter;

    private ListView mListView;
    private EditText mEditText;
    private Button mSendButton;
    private boolean messageSendInProgress;
    private boolean wearConnected;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if( !init() ) {
            finish();
            return;
        }

        initGoogleApiClient();
    }

    private void initGoogleApiClient() {
        mApiClient = new GoogleApiClient.Builder( this )
                .addApi( Wearable.API )
                .addConnectionCallbacks( this )
                .addOnConnectionFailedListener( this )
                .build();

        mApiClient.connect();
    }

    @Override
    protected void onDestroy() {
        wearConnected = false;
        if (mApiClient != null) {
            mApiClient.unregisterConnectionCallbacks( this );
            if (mApiClient.isConnected() || mApiClient.isConnecting()) {
                mApiClient.disconnect();
            }
        }
        super.onDestroy();
    }

    private boolean init() {
        mListView = (ListView) findViewById( R.id.list_view );
        mEditText = (EditText) findViewById( R.id.input );
        mSendButton = (Button) findViewById( R.id.btn_send );

        if( mListView == null || mEditText == null || mSendButton == null ) {
            return false;
        }

        mAdapter = new ArrayAdapter<String>( this, android.R.layout.simple_list_item_1 );
        mListView.setAdapter( mAdapter );

        mSendButton.setOnClickListener( new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String text = WearMessage.normalizeText(mEditText.getText());
                if (TextUtils.isEmpty(text) || messageSendInProgress || !isWearConnected()) {
                    return;
                }

                messageSendInProgress = true;
                updateSendButtonState();
                sendMessage(WearMessage.WEAR_MESSAGE_PATH, text, true);
            }
        });
        updateSendButtonState();

        return true;
    }

    private boolean isWearConnected() {
        return wearConnected && mApiClient != null && mApiClient.isConnected();
    }

    private void updateSendButtonState() {
        if (mSendButton != null) {
            mSendButton.setEnabled(!messageSendInProgress && isWearConnected()
                    && !isFinishing() && !isDestroyed());
        }
    }

    private void sendMessage(
            final String path,
            final String text,
            final boolean reportUserResult) {
        new Thread( new Runnable() {
            @Override
            public void run() {
                boolean messageSent = false;
                try {
                    GoogleApiClient apiClient = mApiClient;
                    if (apiClient == null || !apiClient.isConnected()) {
                        return;
                    }

                    NodeApi.GetConnectedNodesResult nodes = Wearable.NodeApi
                            .getConnectedNodes(apiClient)
                            .await(MESSAGE_OPERATION_TIMEOUT_SECONDS, TimeUnit.SECONDS);
                    if (nodes == null || nodes.getNodes() == null) {
                        return;
                    }

                    for (Node node : nodes.getNodes()) {
                        if (node == null || node.getId() == null) {
                            continue;
                        }

                        MessageApi.SendMessageResult result = Wearable.MessageApi.sendMessage(
                                apiClient,
                                node.getId(),
                                path,
                                WearMessage.encode(text)).await(
                                MESSAGE_OPERATION_TIMEOUT_SECONDS,
                                TimeUnit.SECONDS);
                        if (result != null && result.getStatus() != null
                                && result.getStatus().isSuccess()) {
                            messageSent = true;
                        }
                    }
                } catch (RuntimeException ignored) {
                } finally {
                    if (reportUserResult) {
                        completeMessageSend(text, messageSent);
                    }
                }
            }
        }).start();
    }

    private void completeMessageSend(final String sentText, final boolean messageSent) {
        runOnUiThread( new Runnable() {
            @Override
            public void run() {
                if (isFinishing() || isDestroyed()) {
                    return;
                }

                messageSendInProgress = false;
                updateSendButtonState();

                if (!messageSent) {
                    Toast.makeText(
                            MainActivity.this,
                            R.string.message_send_failed,
                            Toast.LENGTH_SHORT).show();
                    return;
                }

                if (mAdapter != null) {
                    mAdapter.add(sentText);
                    mAdapter.notifyDataSetChanged();
                }

                if (mEditText != null
                        && WearMessage.shouldClearInput(mEditText.getText(), sentText)) {
                    mEditText.setText( "" );
                }
            }
        });
    }

    @Override
    public void onConnected(Bundle bundle) {
        if (isFinishing() || isDestroyed()) {
            return;
        }

        wearConnected = true;
        updateSendButtonState();
        sendMessage(WearMessage.START_ACTIVITY, "", false);
    }

    @Override
    public void onConnectionSuspended(int i) {
        wearConnected = false;
        updateSendButtonState();
    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {
        wearConnected = false;
        updateSendButtonState();
    }
}

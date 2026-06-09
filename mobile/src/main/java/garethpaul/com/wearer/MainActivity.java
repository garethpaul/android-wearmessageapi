package garethpaul.com.wearer;


import android.app.Activity;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.wearable.MessageApi;
import com.google.android.gms.wearable.Node;
import com.google.android.gms.wearable.NodeApi;
import com.google.android.gms.wearable.Wearable;


public class MainActivity extends Activity implements GoogleApiClient.ConnectionCallbacks {

    private GoogleApiClient mApiClient;

    private ArrayAdapter<String> mAdapter;

    private ListView mListView;
    private EditText mEditText;
    private Button mSendButton;

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
                .build();

        mApiClient.connect();
    }

    @Override
    protected void onDestroy() {
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
                if (!TextUtils.isEmpty(text)) {
                    mAdapter.add(text);
                    mAdapter.notifyDataSetChanged();

                    sendMessage(WearMessage.WEAR_MESSAGE_PATH, text);
                }
            }
        });

        return true;
    }

    private void sendMessage( final String path, final String text ) {
        new Thread( new Runnable() {
            @Override
            public void run() {
                if (mApiClient == null || !mApiClient.isConnected()) {
                    return;
                }

                boolean messageSent = false;
                NodeApi.GetConnectedNodesResult nodes = Wearable.NodeApi.getConnectedNodes( mApiClient ).await();
                if (nodes == null || nodes.getNodes() == null) {
                    return;
                }

                for (Node node : nodes.getNodes()) {
                    if (node == null || node.getId() == null) {
                        continue;
                    }

                    MessageApi.SendMessageResult result = Wearable.MessageApi.sendMessage(
                            mApiClient, node.getId(), path, WearMessage.encode(text) ).await();
                    if (result != null && result.getStatus() != null && result.getStatus().isSuccess()) {
                        messageSent = true;
                    }
                }

                if (messageSent) {
                    clearMessageInput();
                }
            }
        }).start();
    }

    private void clearMessageInput() {
        runOnUiThread( new Runnable() {
            @Override
            public void run() {
                if (mEditText == null) {
                    return;
                }

                mEditText.setText( "" );
            }
        });
    }

    @Override
    public void onConnected(Bundle bundle) {
        sendMessage(WearMessage.START_ACTIVITY, "");
    }

    @Override
    public void onConnectionSuspended(int i) {

    }
}

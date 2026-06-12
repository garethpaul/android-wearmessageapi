package garethpaul.com.wearer;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.ListView;

public class MainActivity extends Activity {
    private ArrayAdapter<String> mAdapter;

    private ListView mListView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if( !initViews() ) {
            finish();
            return;
        }

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        addIntentMessage(getIntent());
    }

    private boolean initViews() {
        mListView = (ListView) findViewById(R.id.list);

        if( mListView == null ) {
            return false;
        }

        mAdapter = new ArrayAdapter<String>( this, R.layout.list_item );
        mListView.setAdapter( mAdapter );

        return true;
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        addIntentMessage(intent);
    }

    private void addIntentMessage(Intent intent) {
        if (intent == null || !intent.hasExtra(WearMessage.EXTRA_MESSAGE)) {
            return;
        }

        String message = intent.getStringExtra(WearMessage.EXTRA_MESSAGE);
        intent.removeExtra(WearMessage.EXTRA_MESSAGE);
        if (WearMessage.isValidMessageText(message)) {
            addWearMessage(message);
        }
    }

    private void addWearMessage(String text) {
        if (mAdapter == null) {
            return;
        }

        while (WearMessage.shouldRemoveOldestHistoryEntry(mAdapter.getCount())) {
            mAdapter.remove(mAdapter.getItem(0));
        }
        mAdapter.add(text);
        mAdapter.notifyDataSetChanged();
    }
}

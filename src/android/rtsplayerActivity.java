package br.com.stek.rtsplayer;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.media.AudioManager;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.PowerManager;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.Toast;

import java.io.IOException;

public class rtsplayerActivity extends Activity implements SurfaceHolder.Callback, MediaPlayer.OnErrorListener , MediaPlayer.OnPreparedListener {

    private MediaPlayer mediaPlayer;
    private LinearLayout layout;
    private SurfaceView surfaceView;
    private SurfaceHolder surfaceHolder;
    private String videoSrc;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (this.getResources().getConfiguration().orientation != Configuration.ORIENTATION_LANDSCAPE) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
            return;
        }

        Bundle extras  = getIntent().getExtras();
        if (extras != null) {
            videoSrc = extras.getString("VIDEO_URL");
        } else {
            finishWithError();
        }

        Log.d("FLP","rtsplayerActivity videoSrc"+videoSrc);


        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        // create the linear layout to hold our video
        layout = new LinearLayout(this);
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);
        layout.setLayoutParams(layoutParams);

        // add the surfaceView with the current video
        createVideoView();

        // add to the view
        setContentView(layout);
    }

    private void createVideoView() {
        surfaceView = new SurfaceView(getApplicationContext());
        surfaceHolder = surfaceView.getHolder();
        surfaceHolder.addCallback(this);

        layout.addView(surfaceView);
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        try {
            // Surface ready, add the mediaPlayer to it
            mediaPlayer = new MediaPlayer();

            // Setting up media player
            mediaPlayer.setDisplay(surfaceHolder);
            mediaPlayer.setDataSource(videoSrc);
            mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            mediaPlayer.setVolume(0f,0f);
            mediaPlayer.setScreenOnWhilePlaying(true);
            mediaPlayer.setOnPreparedListener(this);
            mediaPlayer.setOnErrorListener(this);

            mediaPlayer.prepareAsync();
        } catch (IOException e) {
            Toast.makeText(getApplicationContext(), "Falha ao abrir video",Toast.LENGTH_SHORT).show();
            e.printStackTrace();
            finishWithError();
        }

    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
//        if (mediaPlayer.isPlaying()) {
//            mediaPlayer.stop();
//            mediaPlayer.release();
//        } else {
//            mediaPlayer.start();
//        }
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        if (mediaPlayer.isPlaying()) {
            mediaPlayer.stop();
            mediaPlayer.release();
        }
    }



    @Override
    public void onPrepared(MediaPlayer mp) {
        Log.d("FLP", "onPrepared fired");
        mediaPlayer.start();
    }


    @Override
    public boolean onError(MediaPlayer mp, int what, int extra) {
        Log.d("FLP", "onError fired");
        Toast.makeText(getApplicationContext(), "Falha ao abrir video", Toast.LENGTH_SHORT).show();
        finishWithError();
        return false;
    }

    @Override
    public void onBackPressed() {
//        super.onBackPressed();
        Log.d("FLP", "DO NOTHING");
        setResult(Activity.RESULT_OK);
        finish();
    }

    private void finishWithError() {
        setResult(100);
        finish();
    }


}

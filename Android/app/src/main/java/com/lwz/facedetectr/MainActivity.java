package com.lwz.facedetectr;

import android.content.Intent;
import android.graphics.Bitmap;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.support.v4.content.FileProvider;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.JsonObject;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;

public class MainActivity extends AppCompatActivity {

    private static final String LOG_TAG = MainActivity.class.getSimpleName();

    static final int REQUEST_IMAGE_CAPTURE = 1;
    static final int REQUEST_IMAGE_PICK = 2;

    private String currentPhotoPath;

    ImageView imageView;
    TextView stateTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        /** Initialize Objects **/
        final Button button_take_photo = findViewById(R.id.button_take_photo);
        final Button button_detect = findViewById(R.id.button_detect);
        imageView = findViewById(R.id.iv_photo);
        stateTextView = findViewById(R.id.tv_state);

        stateTextView.setText("State: Waiting user action");

        /** Bind button listeners **/
        button_take_photo.setOnClickListener(new TakePhotoListener());

        button_detect.setOnClickListener(new View.OnClickListener(){

            @Override
            public void onClick(View view) {
                if(currentPhotoPath == null) {
                    new DownloadPhotoTask().execute("marked_test.jpg");
                } else {
                    new UploadPhotoTask().execute();
                }
            }
        });

    }

    class TakePhotoListener implements View.OnClickListener{

        @Override
        public void onClick(View view) {
            dispatchTakenPictureIntent();
        }
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        //galleryAddPic();

        switch(requestCode) {
            case REQUEST_IMAGE_CAPTURE:
                if(resultCode == RESULT_OK) {
                    galleryAddPic();
                    File f = new File(currentPhotoPath);
                    imageView.setImageURI(Uri.fromFile(f));
                }
                break;
            default:
                break;
        }
    }

    private void dispatchTakenPictureIntent() {
        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

        if(takePictureIntent.resolveActivity(getPackageManager()) != null) {
            File photoFile = null;
            try {
                photoFile = createImageFile();
            } catch (IOException e) {

            }

            if (photoFile != null) {
                Uri photoURI = FileProvider.getUriForFile(this, "com.lwz.facedetectr", photoFile);
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI);
                startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE);
            }
        }

    }

    private File createImageFile() throws IOException {

        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "JPEG_" + timeStamp + "_";
        File storageDir = getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        File image = File.createTempFile(
                imageFileName,
                ".jpg",
                storageDir
        );

        currentPhotoPath = image.getAbsolutePath();
        return image;
    }

    private void galleryAddPic() {
        Intent mediaScanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
        File f = new File(currentPhotoPath);
        Uri contentUri = Uri.fromFile(f);
        mediaScanIntent.setData(contentUri);
        this.sendBroadcast(mediaScanIntent);
    }

    class UploadPhotoTask extends AsyncTask<Void, Void, String> {

        @Override
        protected String doInBackground(Void... voids) {
            stateTextView.setText("State: uploading photo");
            return NetworkUtils.post(currentPhotoPath);
        }

        @Override
        protected void onPostExecute(String s) {
            stateTextView.setText("State: photo uploaded");
            String path = NetworkUtils.getProcessedPhotoPath(s);
            new DownloadPhotoTask().execute(path);
        }
    }

    class DownloadPhotoTask extends AsyncTask<String, Void, Bitmap> {

        @Override
        protected Bitmap doInBackground(String... name) {
            stateTextView.setText("State: Detecting faces");
            return NetworkUtils.getImageFromPath(name[0]);
        }

        @Override
        protected void onPostExecute(Bitmap bitmap) {
            stateTextView.setText("State: done");
            imageView.setImageBitmap(bitmap);
        }
    }
}

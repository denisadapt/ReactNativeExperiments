package com.nativeaddondemo;

import android.util.Log;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.Promise;

public class MyLibraryWrapper extends ReactContextBaseJavaModule {
    static {
        System.loadLibrary("mylibrary");
    }

    MyLibraryWrapper(ReactApplicationContext context) {
        super(context);
    }
    @Override
    public String getName() {
        return "MyLibraryWrapper";
    }

    @ReactMethod
    public void greet( String arg, Promise prom )
    {
        Log.d( "MyLibraryWrapper", "Got string: " + arg );
        prom.resolve( nativeGreet( arg ) );
    }

    @ReactMethod
    public void add( int a, int b, Promise prom )
    {
        prom.resolve( nativeAdd( a, b ) );
    }

    @ReactMethod
    public void readFileContents( String filename, Promise prom )
    {
        prom.resolve( nativeReadFileContent( filename ) );
    }

    private native String nativeGreet(String name);
    private native int nativeAdd(int a, int b);
    private native String nativeReadFileContent(String filename);
}

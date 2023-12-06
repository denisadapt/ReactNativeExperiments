package com.nativeaddondemo;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;

public class MyLibraryWrapper extends ReactContextBaseJavaModule {

    MyLibraryWrapper(ReactApplicationContext context) {
        super(context);
    }
    @Override
    public String getName() {
        return "MyLibraryWrapper";
    }

    @ReactMethod
    public String greet( String arg )
    {
        return "Successfully started up! Got a string: ";
    }
}

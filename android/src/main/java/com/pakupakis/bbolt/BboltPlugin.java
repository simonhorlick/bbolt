package com.pakupakis.bbolt;

import android.content.Context;

import java.io.File;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import mobile.BoltDB;

/** BboltPlugin */
public class BboltPlugin implements MethodCallHandler {
  private static BoltDB db;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "bbolt");
    channel.setMethodCallHandler(new BboltPlugin());

    File appFiles = registrar.activeContext().getFilesDir();
    db = new BoltDB(appFiles.getAbsolutePath());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getKey")) {
      String bucket = call.argument("bucket");
      String key = call.argument("key");

      // Call the go library.
      byte[] value = db.getKey(bucket, key);

      result.success(value);
    } else if (call.method.equals("putKey")) {
      String bucket = call.argument("bucket");
      String key = call.argument("key");
      byte[] value = call.argument("value");

      // Call the go library.
      db.putKey(bucket, key, value);

      result.success(null);
    }  else if (call.method.equals("createBucketIfNotExists")) {
      String bucket = call.argument("bucket");

      // Call the go library.
      db.createBucketIfNotExists(bucket);

      result.success(null);
    } else {
      result.notImplemented();
    }
  }
}

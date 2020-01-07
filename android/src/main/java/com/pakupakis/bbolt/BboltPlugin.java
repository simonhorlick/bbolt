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
  static boolean created = false;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "bbolt");
    channel.setMethodCallHandler(new BboltPlugin());

    File appFiles = registrar.activeContext().getFilesDir();
    if(!created){
    db = new BoltDB(appFiles.getAbsolutePath());
    created = true;
    }
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("get")) {
      try {
        result.success(db.get(call.<String>argument("bucket"), call.<String>argument("key")));
      } catch (Exception e) {
        result.error("error", e.getMessage(), null);
      }
    } else if (call.method.equals("put")) {
      try {
        db.put(
            call.<String>argument("bucket"),
            call.<String>argument("key"),
            call.<byte[]>argument("value"));
        result.success(null);
      } catch (Exception e) {
        result.error("error", e.getMessage(), null);
      }
    } else if (call.method.equals("createBucketIfNotExists")) {
      try {
        db.createBucketIfNotExists(call.<String>argument("bucket"));
        result.success(null);
      } catch (Exception e) {
        result.error("error", e.getMessage(), null);
      }
    } else if (call.method.equals("getKeysByPrefix")) {
      try {
        result.success(
          db.getKeysByPrefix(call.<String>argument("bucket"), call.<String>argument("prefix")));
      } catch (Exception e) {
        result.error("error", e.getMessage(), null);
      }
    } else {
      result.notImplemented();
    }
  }
}

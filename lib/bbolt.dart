import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class Bbolt {
  static const MethodChannel _channel = const MethodChannel('bbolt');

  static Future<Uint8List> getKey(String bucket, String key) async {
    final Uint8List value =
        await _channel.invokeMethod('getKey', {"bucket": bucket, "key": key});
    print("received value for key $key");
    return value;
  }

  static Future<Null> putKey(String bucket, String key, Uint8List value) async {
    await _channel
        .invokeMethod('putKey', {"bucket": bucket, "key": key, "value": value});
    print("put value for key $key");
    return null;
  }

  static Future<Null> createBucketIfNotExists(String bucket) async {
    print("creating bucket $bucket");
    await _channel.invokeMethod('createBucketIfNotExists', {"bucket": bucket});
    print("created bucket $bucket");
    return null;
  }

//  static Future<List<String>> getKeysByPrefix(String bucket, String prefix) async {
//    return _channel.invokeMethod('getKeysByPrefix', {"bucket": bucket, "key": key});
//  }
}

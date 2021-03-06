import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/services.dart';

class Bbolt {
  static const MethodChannel _channel = const MethodChannel('bbolt');

  static Future<Uint8List> getKey(String bucket, String key) async {
    final Uint8List value =
        await _channel.invokeMethod('get', {"bucket": bucket, "key": key});
    print("received value for key $key");
    return value;
  }

  static Future<Null> putKey(String bucket, String key, Uint8List value) async {
    await _channel
        .invokeMethod('put', {"bucket": bucket, "key": key, "value": value});
    print("put value for key $key");
    return null;
  }

  static Future<Null> deleteKey(String bucket, String key) async {
    await _channel.invokeMethod('delete', {"bucket": bucket, "key": key});
    print("delete key $key");
    return null;
  }

  static Future<Null> createBucketIfNotExists(String bucket) async {
    print("creating bucket $bucket");
    await _channel.invokeMethod('createBucketIfNotExists', {"bucket": bucket});
    print("created bucket $bucket");
    return null;
  }

  static Future<List<String>> getKeysByPrefix(
      String bucket, String prefix) async {
    final Uint8List encodedKeysList = await _channel
        .invokeMethod('getKeysByPrefix', {"bucket": bucket, "prefix": prefix});

    if (encodedKeysList == null) {
      return List<String>();
    }

    // Parse a list of keys from the returned byte array. The keys are null
    // separated.
    var keys = List<String>();
    var currentKey = List<int>();
    for (var k in encodedKeysList) {
      if (k == 0) {
        keys.add(utf8.decode(currentKey));
        currentKey.clear();
      } else {
        currentKey.add(k);
      }
    }
    return keys;
  }
}

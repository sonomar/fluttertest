// lib/services/asset_cache_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AssetCacheService {
  // --- Singleton Pattern ---
  AssetCacheService._privateConstructor();
  static final AssetCacheService instance =
      AssetCacheService._privateConstructor();

  // --- State ---
  // In-memory cache for the final prepared GLTF data URL to avoid reprocessing.
  final Map<String, String> _gltfDataCache = {};
  // In-memory cache for local file paths to avoid repeated disk I/O.
  final Map<String, File> _fileCache = {};
  bool _isCacheDirInitialized = false;
  late final Directory _cacheDir;

  // --- Private Helper Methods ---

  /// Ensures the cache directory is initialized.
  Future<void> _ensureCacheDirectory() async {
    if (_isCacheDirInitialized) return;
    _cacheDir = await getApplicationDocumentsDirectory();
    _isCacheDirInitialized = true;
  }

  /// Downloads a file from a URL and caches it on the device if it's not
  /// already present. Returns the local [File] object.
  Future<File> _getOrCacheFile(String fileUrl) async {
    await _ensureCacheDirectory();

    // Use the filename as the cache key.
    final String fileName = p.basename(Uri.parse(fileUrl).path);
    final File localFile = File(p.join(_cacheDir.path, fileName));

    // Check in-memory cache first
    if (_fileCache.containsKey(localFile.path)) {
      return _fileCache[localFile.path]!;
    }

    // Check on-disk cache next
    if (await localFile.exists()) {
      print('AssetCacheService: Found "$fileName" in disk cache.');
      _fileCache[localFile.path] = localFile; // Add to in-memory cache
      return localFile;
    }

    // If not cached, download it.
    print('AssetCacheService: Caching "$fileName" from $fileUrl');
    try {
      final dio = Dio();
      await dio.download(fileUrl, localFile.path);
      _fileCache[localFile.path] = localFile; // Add to in-memory cache
      return localFile;
    } catch (e) {
      print('AssetCacheService: Failed to download $fileUrl. Error: $e');
      throw Exception('Failed to download required asset: $fileName');
    }
  }

  // --- Public API ---

  /// Fetches a GLTF model, embeds its required .bin file, resolves all texture
  /// paths to be absolute, and returns a self-contained data URL for rendering.
  Future<String?> getPreparedGltfDataUrl(String gltfUrl) async {
    // 1. Check the in-memory cache for the final prepared data.
    if (_gltfDataCache.containsKey(gltfUrl)) {
      print(
          'AssetCacheService: Returning fully prepared GLTF data for $gltfUrl from memory cache.');
      return _gltfDataCache[gltfUrl];
    }

    print('AssetCacheService: Preparing new GLTF data for $gltfUrl');
    try {
      final dio = Dio();
      final Uri gltfUri = Uri.parse(gltfUrl);

      // 2. Fetch the main .gltf JSON file.
      final response = await dio.get<String>(gltfUrl);
      final gltfJsonString = response.data;
      if (gltfJsonString == null) return null;

      final Map<String, dynamic> gltfData = jsonDecode(gltfJsonString);

      // 3. Resolve image texture paths to be absolute URLs.
      // This correctly handles textures in sub-folders (e.g., "textures/image.png").
      if (gltfData.containsKey('images') && gltfData['images'] is List) {
        for (var image in gltfData['images']) {
          if (image is Map && image.containsKey('uri')) {
            String relativePath = image['uri'];
            // Uri.resolve is the correct way to join a base URL and a relative path.
            if (!Uri.parse(relativePath).isAbsolute) {
              image['uri'] = gltfUri.resolve(relativePath).toString();
            }
          }
        }
      }

      // 4. Discover, download, and embed the required .bin file.
      if (gltfData.containsKey('buffers') &&
          gltfData['buffers'] is List &&
          gltfData['buffers'].isNotEmpty) {
        // Find the relative path of the .bin file from the gltf data.
        final String binRelativePath = gltfData['buffers'][0]['uri'];
        // Create the full URL for the .bin file.
        final String binFullUrl = gltfUri.resolve(binRelativePath).toString();

        // Download/cache the .bin file and get the local File object.
        final File binFile = await _getOrCacheFile(binFullUrl);
        final List<int> binBytes = await binFile.readAsBytes();

        // Encode the .bin data and embed it into the GLTF json.
        final String binDataUri =
            'data:application/octet-stream;base64,${base64Encode(binBytes)}';
        gltfData['buffers'][0]['uri'] = binDataUri;
      } else {
        print('AssetCacheService: .gltf file has no buffers to embed.');
      }

      // 5. Create the final self-contained data URL.
      final String modifiedGltfJson = jsonEncode(gltfData);
      final String finalDataUrl =
          'data:model/gltf+json;base64,${base64Encode(utf8.encode(modifiedGltfJson))}';

      // 6. Cache the final result in memory and return it.
      _gltfDataCache[gltfUrl] = finalDataUrl;
      return finalDataUrl;
    } catch (e) {
      print('AssetCacheService: Failed to prepare GLTF data URL. Error: $e');
      return null;
    }
  }
}

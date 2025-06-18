import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AssetCacheService {
  // --- Configuration ---
  static const String _s3BaseUrl =
      'https://deins.s3.eu-central-1.amazonaws.com'; // IMPORTANT: The base URL of your S3 bucket
  static const String _binFileUrl =
      '$_s3BaseUrl/Objects3d/kloppocar/20251005-DEINS_Card_Kloppocar_FINAL.bin'; // IMPORTANT: Replace with your actual .bin file URL
  static const String _binFileName = '20251005-DEINS_Card_Kloppocar_FINAL.bin';

  // --- Singleton Pattern ---
  AssetCacheService._privateConstructor();
  static final AssetCacheService instance =
      AssetCacheService._privateConstructor();

  // --- State ---
  String? _cachedBinPath;
  bool _isInitialized = false;

  // In-Memory Cache for prepared GLTF data.
  final Map<String, String> _gltfDataCache = {};

  // --- START OF FIX ---
  // This is the complete implementation of the initialize method.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String localPath = '${appDir.path}/$_binFileName';
      final File localBinFile = File(localPath);

      // Check if the file already exists in the cache.
      if (await localBinFile.exists()) {
        print('AssetCacheService: .bin file found in cache.');
        _cachedBinPath = localPath;
      } else {
        // If not, download it from the S3 URL.
        print('AssetCacheService: .bin file not found. Downloading...');
        final dio = Dio();
        await dio.download(_binFileUrl, localPath);
        print(
            'AssetCacheService: .bin file downloaded and cached successfully.');
        _cachedBinPath = localPath;
      }
      _isInitialized = true;
    } catch (e) {
      print('AssetCacheService: Failed to initialize. Error: $e');
      // Handle error appropriately, maybe retry later.
    }
  }
  // --- END OF FIX ---

  Future<String?> getPreparedGltfDataUrl(String gltfUrl) async {
    if (!_isInitialized || _cachedBinPath == null) {
      print('AssetCacheService Error: Service not initialized.');
      return null;
    }

    // Check the cache first.
    if (_gltfDataCache.containsKey(gltfUrl)) {
      print('AssetCacheService: Returning cached GLTF data for $gltfUrl');
      return _gltfDataCache[gltfUrl];
    }

    try {
      print('AssetCacheService: Preparing new GLTF data for $gltfUrl');
      final dio = Dio();
      final response = await dio.get<String>(gltfUrl);
      final gltfJsonString = response.data;
      if (gltfJsonString == null) return null;

      final Map<String, dynamic> gltfData = jsonDecode(gltfJsonString);

      // Convert relative image paths to absolute URLs
      if (gltfData.containsKey('images') && gltfData['images'] is List) {
        final gltfUri = Uri.parse(gltfUrl);
        final gltfDirectory =
            gltfUri.path.substring(0, gltfUri.path.lastIndexOf('/') + 1);
        for (var image in gltfData['images']) {
          if (image is Map && image.containsKey('uri')) {
            String uri = image['uri'];
            if (!uri.startsWith('http') && !uri.startsWith('data:')) {
              image['uri'] = '$_s3BaseUrl$gltfDirectory$uri';
            }
          }
        }
      }

      // Embed the cached .bin file data
      final File binFile = File(_cachedBinPath!);
      final List<int> binBytes = await binFile.readAsBytes();
      final String binDataUri =
          'data:application/octet-stream;base64,${base64Encode(binBytes)}';
      if (gltfData.containsKey('buffers') &&
          gltfData['buffers'] is List &&
          gltfData['buffers'].isNotEmpty) {
        gltfData['buffers'][0]['uri'] = binDataUri;
      } else {
        throw Exception('.gltf file has no buffers to modify.');
      }

      final String modifiedGltfJson = jsonEncode(gltfData);
      final String finalDataUrl =
          'data:model/gltf+json;base64,${base64Encode(utf8.encode(modifiedGltfJson))}';

      // Store the result in the cache
      _gltfDataCache[gltfUrl] = finalDataUrl;

      return finalDataUrl;
    } catch (e) {
      print('AssetCacheService: Failed to prepare GLTF data URL. Error: $e');
      return null;
    }
  }
}

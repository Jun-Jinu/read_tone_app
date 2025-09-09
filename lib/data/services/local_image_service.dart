import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';

class LocalImageService {
  static const String _imagesFolder = 'book_covers';

  /// 앱의 문서 디렉토리에서 이미지 저장 폴더 경로 가져오기
  Future<Directory> _getImagesDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir =
        Directory(path.join(appDocDir.path, _imagesFolder));

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir;
  }

  /// 이미지 파일을 로컬에 저장하고 로컬 경로 반환
  Future<String> saveImageFromFile(File imageFile) async {
    try {
      final Directory imagesDir = await _getImagesDirectory();
      final String fileExtension = path.extension(imageFile.path);
      final String fileName = '${const Uuid().v4()}$fileExtension';
      final String localPath = path.join(imagesDir.path, fileName);

      // 파일 복사
      await imageFile.copy(localPath);

      return localPath;
    } catch (e) {
      debugPrint('이미지 저장 실패: $e');
      rethrow;
    }
  }

  /// 이미지 데이터를 로컬에 저장하고 로컬 경로 반환
  Future<String> saveImageFromBytes(
      Uint8List imageBytes, String fileExtension) async {
    try {
      final Directory imagesDir = await _getImagesDirectory();
      final String fileName = '${const Uuid().v4()}$fileExtension';
      final String localPath = path.join(imagesDir.path, fileName);

      // 파일 생성 및 저장
      final File file = File(localPath);
      await file.writeAsBytes(imageBytes);

      return localPath;
    } catch (e) {
      debugPrint('이미지 저장 실패: $e');
      rethrow;
    }
  }

  /// URL에서 이미지를 다운로드하여 로컬에 저장
  Future<String> downloadAndSaveImage(String imageUrl) async {
    try {
      final Dio dio = Dio();

      // 이미지 다운로드
      final Response<Uint8List> response = await dio.get<Uint8List>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        throw Exception('이미지 다운로드 실패');
      }

      // 파일 확장자 추출 (URL에서 또는 기본값 사용)
      String fileExtension = '.jpg';
      try {
        final uri = Uri.parse(imageUrl);
        final urlPath = uri.path;
        if (urlPath.isNotEmpty) {
          final ext = path.extension(urlPath);
          if (ext.isNotEmpty) {
            fileExtension = ext;
          }
        }
      } catch (e) {
        // URL 파싱 실패 시 기본 확장자 사용
      }

      // 로컬에 저장
      return await saveImageFromBytes(response.data!, fileExtension);
    } catch (e) {
      debugPrint('이미지 다운로드 및 저장 실패: $e');
      rethrow;
    }
  }

  /// 로컬 이미지 파일 삭제
  Future<bool> deleteImage(String localPath) async {
    try {
      final File file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('이미지 삭제 실패: $e');
      return false;
    }
  }

  /// 로컬 이미지가 존재하는지 확인
  Future<bool> imageExists(String localPath) async {
    try {
      final File file = File(localPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// 이미지 경로가 로컬 경로인지 확인
  bool isLocalPath(String imagePath) {
    return imagePath.startsWith('/') ||
        imagePath.startsWith('file://') ||
        (!imagePath.startsWith('http://') && !imagePath.startsWith('https://'));
  }

  /// 저장된 모든 이미지 목록 가져오기
  Future<List<String>> getAllImages() async {
    try {
      final Directory imagesDir = await _getImagesDirectory();
      final List<FileSystemEntity> files = await imagesDir.list().toList();

      return files
          .where((file) => file is File)
          .map((file) => file.path)
          .toList();
    } catch (e) {
      debugPrint('이미지 목록 가져오기 실패: $e');
      return [];
    }
  }

  /// 저장된 이미지 용량 계산
  Future<int> getTotalImageSize() async {
    try {
      final List<String> imagePaths = await getAllImages();
      int totalSize = 0;

      for (String imagePath in imagePaths) {
        final File file = File(imagePath);
        if (await file.exists()) {
          final int fileSize = await file.length();
          totalSize += fileSize;
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('이미지 용량 계산 실패: $e');
      return 0;
    }
  }

  /// 사용하지 않는 이미지 정리 (책 데이터에서 참조되지 않는 이미지들)
  Future<int> cleanupUnusedImages(List<String> usedImagePaths) async {
    try {
      final List<String> allImages = await getAllImages();
      final Set<String> usedPaths = usedImagePaths.toSet();
      int deletedCount = 0;

      for (String imagePath in allImages) {
        if (!usedPaths.contains(imagePath)) {
          final bool deleted = await deleteImage(imagePath);
          if (deleted) {
            deletedCount++;
          }
        }
      }

      return deletedCount;
    } catch (e) {
      debugPrint('사용하지 않는 이미지 정리 실패: $e');
      return 0;
    }
  }
}

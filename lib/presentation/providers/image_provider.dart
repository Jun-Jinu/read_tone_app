import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/local_image_service.dart';

// LocalImageService Provider
final localImageServiceProvider = Provider<LocalImageService>((ref) {
  return LocalImageService();
});

// ImagePicker Provider
final imagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

// 이미지 선택 및 저장을 위한 Provider
final imageManagerProvider = Provider<ImageManager>((ref) {
  final localImageService = ref.watch(localImageServiceProvider);
  final imagePicker = ref.watch(imagePickerProvider);
  return ImageManager(localImageService, imagePicker);
});

class ImageManager {
  final LocalImageService _localImageService;
  final ImagePicker _imagePicker;

  ImageManager(this._localImageService, this._imagePicker);

  /// 갤러리에서 이미지 선택하여 로컬에 저장
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final String localPath =
            await _localImageService.saveImageFromFile(imageFile);
        return localPath;
      }
      return null;
    } catch (e) {
      throw Exception('이미지 선택 실패: $e');
    }
  }

  /// 카메라로 사진 촬영하여 로컬에 저장
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final String localPath =
            await _localImageService.saveImageFromFile(imageFile);
        return localPath;
      }
      return null;
    } catch (e) {
      throw Exception('사진 촬영 실패: $e');
    }
  }

  /// URL에서 이미지 다운로드하여 로컬에 저장
  Future<String> downloadImageFromUrl(String imageUrl) async {
    try {
      return await _localImageService.downloadAndSaveImage(imageUrl);
    } catch (e) {
      throw Exception('이미지 다운로드 실패: $e');
    }
  }

  /// 로컬 이미지 삭제
  Future<bool> deleteImage(String localPath) async {
    return await _localImageService.deleteImage(localPath);
  }

  /// 이미지가 로컬 경로인지 확인
  bool isLocalPath(String imagePath) {
    return _localImageService.isLocalPath(imagePath);
  }

  /// 이미지가 존재하는지 확인
  Future<bool> imageExists(String localPath) async {
    return await _localImageService.imageExists(localPath);
  }

  /// 저장된 모든 이미지 경로 가져오기
  Future<List<String>> getAllImages() async {
    return await _localImageService.getAllImages();
  }

  /// 총 이미지 용량 계산
  Future<int> getTotalImageSize() async {
    return await _localImageService.getTotalImageSize();
  }

  /// 사용하지 않는 이미지 정리
  Future<int> cleanupUnusedImages(List<String> usedImagePaths) async {
    return await _localImageService.cleanupUnusedImages(usedImagePaths);
  }
}

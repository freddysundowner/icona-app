import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<String?> pickMedia({bool isVideo = false}) async {
  final ImagePicker imgPicker = ImagePicker();

  XFile? mediaPicked = isVideo
      ? await imgPicker.pickVideo(source: ImageSource.gallery) // For videos
      : await imgPicker.pickImage(
          source: ImageSource.gallery, imageQuality: 40); // For images

  return mediaPicked?.path;
}

choseImageFromLocalFiles(
    {CropAspectRatio aspectRatio = const CropAspectRatio(ratioX: 2, ratioY: 3),
    int maxSizeInKB = 1024,
    int minSizeInKB = 5,
    ImageSource? imgSource,
    bool isVideo = false}) async {
  ImagePicker imgPicker = ImagePicker();
  if (imgSource == null) {
    return;
  }
  if (isVideo) {
    XFile? mediaPicked = isVideo
        ? await imgPicker.pickVideo(source: ImageSource.gallery) // For videos
        : await imgPicker.pickImage(
            source: imgSource, imageQuality: 40); // For images

    return mediaPicked?.path;
  }

  XFile? imagePicked = await imgPicker.pickImage(
    source: imgSource,
    imageQuality: 40,
  );

  if (imagePicked != null) {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePicked.path,
      aspectRatio: aspectRatio,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      return croppedFile.path;
    }
  }
}

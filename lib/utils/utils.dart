import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Added for compression

// ... other code

// Function to pick an image and compress it

// ... other code

pickAndCompressImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);

  if (file != null) {
    // Compress the image
    var result = await FlutterImageCompress.compressWithFile(
      file.path,
      quality: 70, // Adjust quality as needed (0-100)
      // minWidth: 1000, // Optional: set minimum width
      // minHeight: 1000, // Optional: set minimum height
    );

    // Handle potential errors
    if (result != null) {
      return result; // Return compressed image bytes
    } else {
      return null; // Return null if compression fails
    }
  }
}

// ... other code

showSnackBar(String content, BuildContext context) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

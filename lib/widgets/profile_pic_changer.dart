import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import 'shadow_circle.dart';

/// A reusable function that shows a dialog for changing the user's profile picture.
Future<void> showProfilePicModal(BuildContext context) async {
  final List<String> profilePicOptions = List.generate(
      5,
      (index) =>
          'https://deins.s3.eu-central-1.amazonaws.com/profile/p${index + 1}.png');
  String? selectedImageUrl;
  bool isUpdating = false;

  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Choose a Profile Picture'),
            content: SizedBox(
              width: double.maxFinite,
              child: isUpdating
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Updating...")
                      ],
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      itemCount: profilePicOptions.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemBuilder: (context, index) {
                        final imageUrl = profilePicOptions[index];
                        final isSelected = selectedImageUrl == imageUrl;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedImageUrl = imageUrl;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.purple, width: 3)
                                  : null,
                            ),
                            child: shadowCircle(imageUrl, 30.0, true),
                          ),
                        );
                      },
                    ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed:
                    isUpdating ? null : () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                onPressed: (selectedImageUrl == null || isUpdating)
                    ? null
                    : () async {
                        setModalState(() {
                          isUpdating = true;
                        });

                        final userModel =
                            Provider.of<UserModel>(context, listen: false);
                        bool success = await userModel
                            .updateUserProfileImg(selectedImageUrl!);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? "Profile picture updated!"
                                  : userModel.errorMessage ??
                                      "Failed to update."),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );
                          Navigator.of(dialogContext).pop();
                        }
                      },
                child: const Text('Change'),
              ),
            ],
          );
        },
      );
    },
  );
}

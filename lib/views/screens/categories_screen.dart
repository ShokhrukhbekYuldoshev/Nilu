import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/views/widgets/dialogs/double_action_dialog.dart';

import '../../utils/constants.dart';
import '../../utils/preferences.dart';
import '../widgets/buttons/primary_button.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController _profileController = Get.find();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Preferences.getTheme() ? darkGrayColor : gray100Color,
        elevation: 0,
        title: Text(
          'Categories',
          style: TextStyle(
            color:
                Preferences.getTheme() ? primaryUltraLightColor : textDarkColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyText1!.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              final TextEditingController _newCategoryController =
                  TextEditingController();
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("New category",
                              style: h5(
                                Theme.of(context).textTheme.bodyText1!.color,
                              )),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 44,
                            child: TextField(
                              controller: _newCategoryController,
                              autofocus: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                labelText: 'Category name',
                                labelStyle: bodyText(textPlaceholderColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide:
                                      const BorderSide(color: borderColor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: PrimaryButton(
                                    text: 'Save category',
                                    onPressed: () {
                                      firestore
                                          .collection('users')
                                          .doc(_profileController.user['id'])
                                          .update({
                                        'categories': FieldValue.arrayUnion(
                                          [_newCategoryController.text],
                                        ),
                                      });
                                      _profileController.updateUserData();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(
        () => _profileController.user['categories'].isEmpty
            ? Center(
                child: Text(
                  'No categories found',
                  style: bodyText(Theme.of(context).textTheme.bodyText2!.color),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),
                itemCount: _profileController.user['categories'].length,
                itemBuilder: (context, index) {
                  final String category =
                      _profileController.user['categories'][index];
                  return Column(
                    children: [
                      CategoryTile(category: category),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({Key? key, required this.category}) : super(key: key);

  final String category;

  @override
  Widget build(BuildContext context) {
    final ProfileController _profileController = Get.find();
    return Container(
      height: 44,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Preferences.getTheme() ? mediumGrayColor : borderColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category,
              style: bodyText(Theme.of(context).textTheme.bodyText1!.color),
            ),
          ),
          PopupMenuButton(
            child: Icon(
              Icons.more_vert,
              color: Preferences.getTheme() ? primaryLightColor : primaryColor,
              size: 24,
            ),
            onSelected: (value) {
              if (value == 'Edit') {
                updateCategory(
                  context,
                  category,
                );
              } else if (value == 'Delete') {
                showDialog(
                  context: context,
                  builder: (context) {
                    return DoubleActionDialog(
                      title: 'Delete category',
                      content: 'Are you sure you want to delete this sale?',
                      confirm: "Delete",
                      cancel: 'Cancel',
                      onConfirm: () {
                        try {
                          firestore
                              .collection('users')
                              .doc(_profileController.user['id'])
                              .update({
                            'categories': FieldValue.arrayRemove([category]),
                          });
                          _profileController.updateUserData();
                          successSnackbar(
                            'Category deleted',
                          );
                        } catch (e) {
                          errorSnackbar(
                            'Error deleting category',
                          );
                        }
                        Navigator.pop(context);
                      },
                      onCancel: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Edit',
                child: Text(
                  'Edit',
                  style: bodyText(Theme.of(context).textTheme.bodyText1!.color),
                ),
              ),
              PopupMenuItem<String>(
                value: 'Delete',
                child: Text(
                  'Delete',
                  style: bodyText(redColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<dynamic> updateCategory(BuildContext context, String category) {
    final ProfileController _profileController = Get.find();
    final TextEditingController _newCategoryController =
        TextEditingController();
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Edit category",
                      style: h5(
                        Theme.of(context).textTheme.bodyText1!.color,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _newCategoryController,
                        autofocus: true,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          labelText: 'Category name',
                          labelStyle: bodyText(textPlaceholderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: PrimaryButton(
                              text: 'Save category',
                              onPressed: () async {
                                List updatedCategories = _profileController
                                    .user['categories']
                                    .toList();
                                updatedCategories.remove(category);
                                updatedCategories
                                    .add(_newCategoryController.text.trim());
                                if (_newCategoryController.text.trim() == '') {
                                  errorSnackbar(
                                    'Category name cannot be empty',
                                  );
                                  return;
                                }
                                try {
                                  await firestore
                                      .collection('users')
                                      .doc(_profileController.user['id'])
                                      .update({
                                    'categories': updatedCategories,
                                  });
                                  successSnackbar(
                                    'Category updated successfully',
                                  );
                                  _profileController.updateUserData();
                                } catch (e) {
                                  errorSnackbar(e.toString());
                                }
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

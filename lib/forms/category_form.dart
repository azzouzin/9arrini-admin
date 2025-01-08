import 'package:app_admin/components/custom_buttons.dart';
import 'package:app_admin/components/image_textfield.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/providers/categories_provider.dart';
import 'package:app_admin/providers/dashboard_providers.dart';
import 'package:app_admin/providers/user_role_provider.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../models/category.dart';
import '../services/firebase_service.dart';

class CategoryForm extends ConsumerStatefulWidget {
  const CategoryForm({Key? key, required this.category}) : super(key: key);

  final Category? category;

  @override
  ConsumerState<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<CategoryForm> {
  late String _submitBtnText;
  late String _dialogText;
  var nameCtlr = TextEditingController();
  var thumbnailUrlCtlr = TextEditingController();
  final _btnCtlr = RoundedLoadingButtonController();
  var formKey = GlobalKey<FormState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'categories';
  XFile? _selectedImage;

  _onPickImage() async {
    XFile? image = await AppService().pickImage();
    if (image != null) {
      _selectedImage = image;
      thumbnailUrlCtlr.text = image.name;
    }
  }

  void _handleSubmit() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (hasAccess(ref)) {
        _btnCtlr.start();
        if (_selectedImage != null) {
          //local image
          await FirebaseService().uploadImageToFirebaseHosting(_selectedImage!, 'category_thumbnails').then((String? imgUrl) async {
            if (imgUrl != null) {
              setState(() => thumbnailUrlCtlr.text = imgUrl);
              _uploadProcedures();
            } else {
              setState(() {
                _selectedImage = null;
                thumbnailUrlCtlr.clear();
              });
              _btnCtlr.reset();
            }
          });
        } else {
          //network image
          _uploadProcedures();
        }
      } else {
        openCustomDialog(context, Config.testingDialog, '');
      }
    }
  }

  _uploadProcedures() async {
    await uploadCategory().then((_) async {
      ref.read(categoriesProvider.notifier).getCategories();
      ref.invalidate(categoriessCountProvider);
      debugPrint('Upload Complete');
      _btnCtlr.success();
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      openCustomDialog(context, _dialogText, '');
    });
  }

  Future uploadCategory() async {
    String docId = widget.category == null ? firestore.collection(collectionName).doc().id : widget.category!.id!;
    int quizCount = widget.category == null ? 0 : widget.category!.quizCount!;
    int orderIndex = widget.category == null ? 0 : widget.category?.orderIndex ?? 0;

    Category d = Category(
      id: docId,
      name: nameCtlr.text,
      thumbnailUrl: thumbnailUrlCtlr.text,
      quizCount: quizCount,
      orderIndex: orderIndex,
    );
    Map<String, dynamic> data = Category.getMap(d);

    await firestore.collection(collectionName).doc(docId).set(data, SetOptions(merge: true));
  }

  @override
  void initState() {
    _submitBtnText = widget.category == null ? 'Upload Category' : 'Update Category';
    _dialogText = widget.category == null ? 'Uploaded Successfully!' : 'Updated Successfully!';
    if (widget.category != null) {
      nameCtlr.text = widget.category!.name!;
      thumbnailUrlCtlr.text = widget.category!.thumbnailUrl!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomButtons.submitButton(
          context,
          buttonController: _btnCtlr,
          text: _submitBtnText,
          width: 300,
          onPressed: () => _handleSubmit(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: const CircleAvatar(
                  child: Icon(Icons.close),
                ),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Category Name',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              TextFormField(
                  controller: nameCtlr,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Enter Category Name',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => nameCtlr.clear(),
                      )),
                  validator: (value) {
                    if (value!.isEmpty) return 'Value is empty';
                    return null;
                  }),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Category Thumbnail Image',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ImageTextField(
                      imageCtrl: thumbnailUrlCtlr,
                      imageFile: _selectedImage,
                      onClear: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      onPickImage: _onPickImage,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:app_admin/components/top_title.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/models/category.dart';
import 'package:app_admin/providers/dashboard_providers.dart';
import 'package:app_admin/providers/user_role_provider.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/tabs/categories/category_order.dart';
import 'package:app_admin/utils/cached_image_filter.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../components/custom_buttons.dart';
import '../../components/custom_dialogs.dart';
import '../../forms/category_form.dart';
import '../../providers/categories_provider.dart';

class Categories extends ConsumerStatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  ConsumerState<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends ConsumerState<Categories> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final String collectionName = 'categories';
  final _deleteBtnCtlr = RoundedLoadingButtonController();
  final _addFeaturedBtnCtlr = RoundedLoadingButtonController();

  Future _onDelete(Category d) async {
    await FirebaseService().deleteContent(collectionName, d.id!);
    await FirebaseService().deleteRelatedQuizesAndQuestions(d.id!);
    ref.read(categoriesProvider.notifier).getCategories();
    ref.invalidate(categoriessCountProvider);
  }

  _handleDelete(Category d) async {
    if (hasAccess(ref)) {
      _deleteBtnCtlr.start();
      await _onDelete(d).then((value) {
        ref.invalidate(categoriessCountProvider);
        _deleteBtnCtlr.success();
        if (!mounted) return;
        Navigator.pop(context);
        openCustomDialog(context, 'Deleted Successfully!', '');
      });
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  _handleAddToFeatured(Category category) async {
    final navigator = Navigator.of(context);
    if (hasAdminAccess(ref)) {
      if (category.featured == false) {
        _addFeaturedBtnCtlr.start();
        await FirebaseService().addCategoryToFeatured(category.id!);
        ref.read(categoriesProvider.notifier).getCategories();
        _addFeaturedBtnCtlr.success();
        navigator.pop();
        if (!mounted) return;
        openCustomDialog(context, 'Added Successfully', '');
      } else {
        navigator.pop();
        openCustomDialog(context, 'Already Exists!',
            'This item is already available in the feature list');
      }
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: TopTitle(title: 'Categories'),
              ),
              const Spacer(),
              CustomButtons.customOutlineButton(
                context,
                icon: LineIcons.sortAmountDown,
                text: 'Set Order',
                bgColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                onPressed: () {
                  CustomDialogs.openResponsiveDialog(context,
                      widget: const SetCategoryOrder());
                },
              ),
              const SizedBox(width: 10),
              CustomButtons.customOutlineButton(
                context,
                icon: LineIcons.plus,
                text: 'Add Category',
                bgColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                onPressed: () => CustomDialogs.openResponsiveDialog(context,
                    widget: const CategoryForm(category: null)),
              ),
            ],
          ),
          categories.isEmpty
              ? const Center(
                  child: Text('No Categories Found'),
                )
              : _buildCategories(context, categories),
        ],
      ),
    );
  }

  GridView _buildCategories(BuildContext context, List<Category> categories) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppService.getCrossAxisCount(context),
        childAspectRatio: AppService.getChildAspectRatio(context),
      ),
      itemCount: categories.length,
      itemBuilder: (BuildContext context, int index) {
        final Category d = categories[index];
        return _categoryTile(context, d);
      },
    );
  }

  GridTile _categoryTile(BuildContext context, Category d) {
    return GridTile(
        header: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                child: const CircleAvatar(
                  radius: 18,
                  child: Icon(
                    Icons.edit,
                    size: 18,
                  ),
                ),
                onTap: () => CustomDialogs.openResponsiveDialog(context,
                    widget: CategoryForm(category: d)),
              ),
              const SizedBox(
                width: 5,
              ),
              InkWell(
                child: const CircleAvatar(
                  radius: 18,
                  child: Icon(
                    Icons.add,
                    size: 18,
                  ),
                ),
                onTap: () => CustomDialogs.openActionDialog(
                  context,
                  actionButtonText: 'Add',
                  title: 'Add to Featured?',
                  message:
                      'Do you want to add this category to the featured section?',
                  onAction: () => _handleAddToFeatured(d),
                  actionBtnController: _addFeaturedBtnCtlr,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              InkWell(
                  child: const CircleAvatar(
                    radius: 18,
                    child: Icon(
                      Icons.delete,
                      size: 18,
                    ),
                  ),
                  onTap: () {
                    CustomDialogs.openActionDialog(
                      context,
                      title: 'Delete This Category?',
                      message:
                          "Do you want to delete this category and it's contents?\nWarning: All of the quizes and questions included to this category will be deleted too!",
                      onAction: () => _handleDelete(d),
                      actionBtnController: _deleteBtnCtlr,
                    );
                  }),
            ],
          ),
        ),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: CustomCacheImageWithDarkFilterFull(
                imageUrl: d.thumbnailUrl.toString(),
                radius: 10,
                width: 600,
                height: 300,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 30, bottom: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name!,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white),
                    ),
                    Text(
                      'Quiz Count: ${d.quizCount}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}

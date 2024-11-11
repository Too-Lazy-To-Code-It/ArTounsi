import 'package:flutter/material.dart';
import 'add_product_form.dart';
import '../../theme/app_theme.dart';

class AddProductButton extends StatelessWidget {
  final VoidCallback? onProductAdded;

  const AddProductButton({Key? key, this.onProductAdded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => AddProductForm(onProductAdded: onProductAdded),
          ),
        );
      },
      backgroundColor: AppTheme.primaryColor,
      child: const Icon(Icons.add),
    );
  }
}
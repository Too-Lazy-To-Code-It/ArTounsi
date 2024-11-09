import 'package:Artounsi/pages/Shop/add_product_form.dart';
import 'package:flutter/material.dart';

class AddProductButton extends StatelessWidget {
  final VoidCallback? onProductAdded;

  const AddProductButton({super.key, this.onProductAdded});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return AddProductForm(onProductAdded: onProductAdded);
          },
        );
      },
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.add),
    );
  }
}

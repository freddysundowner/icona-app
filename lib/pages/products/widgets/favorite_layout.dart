import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../models/product.dart';

Widget favoriteIcon(Product product) {
  return FirebaseAuth.instance.currentUser!.uid != product.ownerId?.id
      ? InkWell(
          onTap: () {
            productController.addToFavorite(product);
          },
          child: Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(50)),
            child: Icon(Icons.favorite_border,
                color: product.favorited?.indexWhere((element) =>
                            element ==
                            FirebaseAuth.instance.currentUser!.uid) !=
                        -1
                    ? Colors.amber
                    : Colors.white),
          ),
        )
      : Container(
          height: 0,
        );
}

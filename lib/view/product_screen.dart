import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns_ventures/models/product_model.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int count = 0;
    List<ProductModel> productsList = [];
    final ValueNotifier<double> totalPrice = ValueNotifier<double>(0);
    return Scaffold(
      appBar: AppBar(title: Text("Thanks"),),
      floatingActionButton: 
          FloatingActionButton.extended(
        onPressed: () {},
        label: ValueListenableBuilder(
            valueListenable: totalPrice,
            builder: (context, value, child) {
              return Text(totalPrice.value.toStringAsFixed(2));
               
            }),
      ),
      body: ValueListenableBuilder(
        valueListenable: totalPrice,
        builder: (context, value, child) {
          return Column(
            children: [
              FutureBuilder<List<ProductModel>>(
                future: fetchProducts(count++),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting
                          //
                          &&
                          count == 1
                      //
                      ) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 200),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 200),
                      child: Text("Something went wrong"),
                    );
                  }
                  if (count == 0 || count == 1) {
                    productsList = snapshot.data ?? [];
                  }
                  return Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: productsList.length,
                      itemBuilder: (context, idx) {
                        var product = productsList[idx];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.grey[200]!, width: 1)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 1,
                                child: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(product.image ?? ""),
                                ),
                              ),
                              Flexible(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.title ?? "N/A"),
                                    Text(product.price ?? "N/A"),
                                  ],
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: Column(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          double price = double.parse(
                                              product.price ?? "0");
                                          totalPrice.value += price;
                                        },
                                        icon: const Icon(
                                          Icons.add,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          double price = double.parse(
                                              product.price ?? "0");
                                          totalPrice.value -= price;
                                        },
                                        icon: const Icon(
                                          Icons.remove,
                                        )),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }
}

Future<List<ProductModel>> fetchProducts(int count) async {
  List<ProductModel> productsList = [];
  if (count == 0) {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      List responseData = jsonDecode(response.body);
      for (var element in responseData) {
        var product = ProductModel.fromJson(element);
        productsList.add(product);
      }
      return productsList;
    } else {
      throw Exception('Failed to load products');
    }
  }
  return [];
}

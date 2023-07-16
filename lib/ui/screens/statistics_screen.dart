import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/controllers/sale_controller.dart';
import 'package:nilu/utils/constants.dart';

import '../../controllers/product_controller.dart';
import '../../utils/preferences.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  static final SaleController _saleController = Get.find();
  final ProfileController _profileController = Get.find();
  final ProductController _productController = Get.find();

  double sales = _saleController.getLastWeekSales();
  String time = 'last_week'.tr;

  @override
  Widget build(BuildContext context) {
    List topProducts = _saleController.getTopProducts(time);
    // print(topProducts);
    final List<String> items = [
      'today'.tr,
      'last_week'.tr,
      'last_month'.tr,
      'last_year'.tr,
      'all_time'.tr,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('statistics'.tr),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 44,
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color:
                          Preferences.getTheme() ? lightGrayColor : borderColor,
                    ),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    underline: Container(),
                    value: time,
                    items: items.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        time = value!;
                        if (value == 'today'.tr) {
                          sales = _saleController.getTodaySales();
                          topProducts = _saleController.getTopProducts(value);
                        } else if (value == 'last_week'.tr) {
                          sales = _saleController.getLastWeekSales();
                          topProducts = _saleController.getTopProducts(value);
                        } else if (value == 'last_month'.tr) {
                          sales = _saleController.getLastMonthSales();
                          topProducts = _saleController.getTopProducts(value);
                        } else if (value == 'last_year'.tr) {
                          sales = _saleController.getLastYearSales();
                          topProducts = _saleController.getTopProducts(value);
                        } else if (value == 'all_time'.tr) {
                          sales = _saleController.getTotalSales();
                          topProducts = _saleController.getTopProducts(value);
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF00AD30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'total_sales'.tr,
                      style: bodyText(whiteColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(
                          sales, _profileController.user['mainCurrency']),
                      style: h5(whiteColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'products_sold'.tr,
                style: h5(Theme.of(context).textTheme.bodyLarge!.color),
              ),
              const SizedBox(height: 20),
              topProducts.isEmpty
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text('no_products_sold'.tr),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: topProducts.length,
                      itemBuilder: (context, index) {
                        var product = topProducts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _productController
                                          .getProduct(product['id'])
                                          .image !=
                                      ''
                                  ? Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedNetworkImage(
                                          imageUrl: _productController
                                              .getProduct(product['id'])
                                              .image!,
                                          placeholder: (context, url) =>
                                              Container(
                                            padding: const EdgeInsets.all(10),
                                            child:
                                                const CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            height: 48,
                                            width: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF80B2FF),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                                'assets/images/box.png'),
                                          ),
                                          height: 48,
                                          width: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF80B2FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child:
                                          Image.asset('assets/images/box.png'),
                                    ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: bodyText(
                                        Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          '${'sold'.tr}: ${product['quantity']}',
                                          style: bodyText(greenColor),
                                        ),
                                        const SizedBox(width: 14),
                                        Text(
                                          '${'total'.tr}: ${formatCurrency(product['quantity'] * product['price'], _profileController.user['mainCurrency'])}',
                                          style: bodyText(greenColor),
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
                    )
            ],
          ),
        ),
      ),
    );
  }
}

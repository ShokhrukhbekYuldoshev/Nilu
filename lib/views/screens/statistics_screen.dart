import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/controllers/sale_controller.dart';
import 'package:nilu/utils/constants.dart';

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

  double sales = _saleController.getLastWeekSales();
  String time = 'last_week'.tr;

  @override
  Widget build(BuildContext context) {
    List topProducts = _saleController.getTopProducts(time);
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
      body: Padding(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
              style: h5(Theme.of(context).textTheme.bodyText1!.color),
            ),
            Expanded(
              child: topProducts.isEmpty
                  ? Center(child: Text('no_products_sold'.tr))
                  : ListView.builder(
                      itemCount: topProducts.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          visualDensity: VisualDensity.compact,
                          title: Text(topProducts[index]['name']),
                          trailing: Text(
                            topProducts[index]['quantity'].toString(),
                            style: h5(
                                Theme.of(context).textTheme.bodyText1!.color),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

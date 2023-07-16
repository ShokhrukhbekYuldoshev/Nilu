import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nilu/controllers/cart_controller.dart';
import 'package:nilu/controllers/client_controller.dart';
import 'package:nilu/controllers/product_controller.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/models/client_model.dart';
import 'package:nilu/utils/preferences.dart';
import 'package:nilu/ui/screens/sale/edit_sale.screen.dart';
import 'package:nilu/ui/widgets/dashed_seperator.dart';
import 'package:nilu/ui/widgets/dialogs/double_action_dialog.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import '../../../controllers/sale_controller.dart';
import '../../../models/product_model.dart';
import '../../../utils/constants.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final SaleController _saleController = Get.find();
  final ClientController _clientController = Get.find();
  final ProductController _productController = Get.find();
  final CartController _cartController = Get.find();
  final ProfileController _profileController = Get.find();

  @override
  void initState() {
    Timer.run(() {
      _saleController.setSalesByDate();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    Timer.run(() {
      _saleController.clearSelectedDateRange();
      _saleController.filterClients.value = [];
      _saleController.setSaleType('All');
      _saleController.filteredSales.value = _saleController.sales;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Preferences.getTheme()
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFE5E5E5),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/sale/add');
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('all_sales'.tr),
        elevation: 0,
      ),
      body: Obx(
        () => Column(
          children: [
            Container(
              height: 8,
              color: Preferences.getTheme()
                  ? Theme.of(context).scaffoldBackgroundColor
                  : whiteColor,
            ),
            Container(
              color: Preferences.getTheme()
                  ? Theme.of(context).scaffoldBackgroundColor
                  : whiteColor,
              height: 40,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                children: [
                  _saleController.sales.length !=
                          _saleController.filteredSales.length
                      ? Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _saleController.filterClients.value = [];
                                _saleController.setSaleType('All');
                                _saleController.clearSelectedDateRange();
                                _saleController.filterSales();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Preferences.getTheme()
                                        ? mediumGrayColor
                                        : borderColor,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.cancel,
                                  color: Preferences.getTheme()
                                      ? lightGrayColor
                                      : iconGrayColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        )
                      : Container(),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return const SelectClientsBottomSheet();
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Preferences.getTheme()
                              ? mediumGrayColor
                              : borderColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            _saleController.filterClients.length ==
                                        _clientController.clients.length ||
                                    _saleController.filterClients.isEmpty
                                ? 'all_clients'.tr
                                : _saleController.filterClients.length == 1
                                    ? '${_saleController.filterClients.length} ${'client'.tr.toLowerCase()}'
                                    : '${_saleController.filterClients.length} ${'clients'.tr.toLowerCase()}',
                            style: bodyText(
                              Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                          ),
                          const Icon(
                            Icons.expand_more,
                            color: iconGrayColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      showDateRangePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ).then(
                        (DateTimeRange? value) {
                          if (value != null) {
                            DateTimeRange fromRange = DateTimeRange(
                              start: DateTime.now(),
                              end: DateTime.now(),
                            );
                            setState(() {
                              fromRange = value;
                              _saleController.setSelectedDateRange(fromRange);
                            });

                            final String range =
                                '${DateFormat('dd/MM/yyyy').format(fromRange.start)} - ${DateFormat('dd/MM/yyyy').format(fromRange.end)}';
                            successSnackbar("${'date'.tr}: $range");
                          }
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Preferences.getTheme()
                              ? mediumGrayColor
                              : borderColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            _saleController.selectedDateRange != null
                                ? '${DateFormat('dd/MM/yyyy').format(_saleController.selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_saleController.selectedDateRange!.end)}'
                                : 'any_date'.tr,
                            style: bodyText(
                              Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                          ),
                          const Icon(
                            Icons.expand_more,
                            color: iconGrayColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('payment'.tr),
                          contentPadding: const EdgeInsets.all(16),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RadioListTile(
                                contentPadding: EdgeInsets.zero,
                                value: 'All',
                                title: Text("all".tr),
                                groupValue: _saleController.saleType.value,
                                activeColor: Preferences.getTheme()
                                    ? primaryLightColor
                                    : primaryColor,
                                onChanged: (String? value) {
                                  _saleController.setSaleType(value!);
                                  Navigator.pop(context);
                                },
                              ),
                              RadioListTile(
                                contentPadding: EdgeInsets.zero,
                                value: 'Debt',
                                title: Text("debt".tr),
                                groupValue: _saleController.saleType.value,
                                activeColor: Preferences.getTheme()
                                    ? primaryLightColor
                                    : primaryColor,
                                onChanged: (String? value) {
                                  _saleController.setSaleType(value!);
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Preferences.getTheme()
                              ? mediumGrayColor
                              : borderColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            _saleController.saleType.value == 'All'
                                ? 'all_sales'.tr
                                : 'debt'.tr,
                            style: bodyText(
                              Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                          ),
                          const Icon(
                            Icons.expand_more,
                            color: iconGrayColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 8,
              color: Preferences.getTheme()
                  ? Theme.of(context).scaffoldBackgroundColor
                  : whiteColor,
            ),
            Expanded(
              child: _saleController.getDatesCount() == 0
                  ? Center(
                      child: Text(
                        'not_found'.tr,
                        style: bodyText(textPlaceholderColor),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 40),
                      itemCount: _saleController.getDatesCount(),
                      itemBuilder: (context, index) {
                        List<Map<String, dynamic>> salesByDate = [];

                        for (var i = 0; i < _saleController.dates.length; i++) {
                          salesByDate.add({
                            'date': _saleController.dates[i],
                            'sales': _saleController
                                .getSalesByDate(_saleController.dates[i]),
                          });
                        }

                        return StickyHeader(
                          header: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            width: double.maxFinite,
                            height: 48,
                            color: const Color(0xFFFFEA9F),
                            child: Row(
                              children: [
                                Text(
                                  DateFormat("dd.MM.yyyy", 'en_US').format(
                                      salesByDate[index]['sales'][0]
                                          .date
                                          .toDate()),
                                  style: h5(textDarkColor),
                                ),
                                const Spacer(),
                                Text(
                                  '${'total'.tr}: ${formatCurrency(_saleController.getTotalSalesByDate(
                                        salesByDate[index]['date'],
                                      ), _profileController.user['mainCurrency'])}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: textPlaceholderColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          content: Container(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Column(
                              children: List.from(
                                salesByDate[index]['sales'].map(
                                  (sale) {
                                    final client = _clientController
                                        .getClient(sale.client);
                                    final time = sale.date.toDate();

                                    return Container(
                                      color: Preferences.getTheme()
                                          ? mediumGrayColor
                                          : whiteColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 16),
                                      margin: const EdgeInsets.only(
                                          left: 16, right: 16, bottom: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${'reciept'.tr}: ${DateFormat("hh:mm a", 'en_US').format(time)}',
                                                style: h6(
                                                  Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color,
                                                ),
                                              ),
                                              const Spacer(),
                                              PopupMenuButton(
                                                child: Icon(
                                                  Icons.more_vert,
                                                  color: Preferences.getTheme()
                                                      ? primaryLightColor
                                                      : primaryColor,
                                                  size: 24,
                                                ),
                                                onSelected: (value) {
                                                  if (value == 'Edit') {
                                                    editSale(sale, client,
                                                        context, time);
                                                  } else if (value ==
                                                      'Delete') {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return DoubleActionDialog(
                                                          title:
                                                              'delete_sale'.tr,
                                                          content:
                                                              'delete_sale_confirmation'
                                                                  .tr,
                                                          confirm: 'delete'.tr,
                                                          cancel: 'cancel'.tr,
                                                          onConfirm: () {
                                                            _saleController
                                                                .deleteSale(
                                                                    sale);
                                                            _saleController
                                                                .setSalesByDate();
                                                            _saleController
                                                                .filterSales();
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          onCancel: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                itemBuilder: (BuildContext
                                                        context) =>
                                                    <PopupMenuEntry<String>>[
                                                  PopupMenuItem<String>(
                                                    value: 'Edit',
                                                    child: Text(
                                                      'edit'.tr,
                                                      style: bodyText(
                                                        Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .color,
                                                      ),
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'Delete',
                                                    child: Text(
                                                      'delete'.tr,
                                                      style: bodyText(redColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.account_circle,
                                                color: iconGrayColor,
                                                size: 28,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                sale.client == ''
                                                    ? 'unnamed_client'.tr
                                                    : _clientController
                                                                .getClient(
                                                                    sale.client)
                                                                .id ==
                                                            ''
                                                        ? 'unnamed_client'.tr
                                                        : client.name,
                                                style: bodyText(
                                                    Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .color),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          const DashedSeperator(),
                                          const SizedBox(height: 12),
                                          for (var i = 0;
                                              i < sale.products.length;
                                              i++)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 12),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          sale.products[i]
                                                              ['name'],
                                                          style: bodyText(
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .color,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                '${sale.products[i]['quantity']} * ${formatCurrency(
                                                                  sale.products[
                                                                          i]
                                                                      ['price'],
                                                                  _profileController
                                                                          .user[
                                                                      'mainCurrency'],
                                                                )}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .color,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              formatCurrency(
                                                                sale.products[i]
                                                                        [
                                                                        'quantity'] *
                                                                    sale.products[
                                                                            i][
                                                                        'price'],
                                                                _profileController
                                                                        .user[
                                                                    'mainCurrency'],
                                                              ),
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium!
                                                                    .color,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          const DashedSeperator(),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${'total'.tr}: ${formatCurrency(sale.price, _profileController.user['mainCurrency'])}',
                                                  style: h6(Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color),
                                                ),
                                                sale.discount > 0
                                                    ? Text(
                                                        '${'discount'.tr}: ${formatCurrency(sale.discount, _profileController.user['mainCurrency'])}',
                                                        style: bodyText(
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .color,
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                                sale.payment == sale.price
                                                    ? Text(
                                                        'paid'.tr,
                                                        style: bodyText(
                                                          greenColor,
                                                        ),
                                                      )
                                                    : sale.payment > 0
                                                        ? Text(
                                                            '${'paid'.tr}: ${formatCurrency(sale.payment, _profileController.user['mainCurrency'])}',
                                                            style: bodyText(
                                                              greenColor,
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                sale.debt > 0
                                                    ? Text(
                                                        '${'debt'.tr}: ${formatCurrency(sale.debt, _profileController.user['mainCurrency'])}',
                                                        style: bodyText(
                                                          redColor,
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                                const SizedBox(height: 16),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void editSale(sale, Client client, BuildContext context, time) {
    List<Product> products = [];
    for (final product in sale.products) {
      for (int quantity = 0; quantity < product['quantity']; quantity++) {
        if (_productController.getProduct(product['id']).id == '') {
          products.add(
            Product(
              id: product['id'],
              name: product['name'],
              price: product['price'],
              quantity: 1,
              code: '',
              owner: '',
            ),
          );
        } else {
          products.add(_productController.getProduct(product['id']));
        }
      }
    }
    _cartController.client = client;

    _cartController.setDiscount(sale.discount);
    if (sale.payment > 0) {
      _cartController.addPayment(
        sale.payment,
        _profileController.user['mainCurrency'],
      );
    }

    _cartController.setComment(sale.comment);
    _cartController.setProducts(products, sale.products);

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditSaleScreen(
          sale: sale,
          title:
              ('${'sale'.tr} ${DateFormat("dd.MM.yyyy", 'en_US').format(time)} ${DateFormat("hh:mm a", 'en_US').format(time)}'),
        ),
      ),
    );
  }
}

class SelectClientsBottomSheet extends StatefulWidget {
  const SelectClientsBottomSheet({Key? key}) : super(key: key);

  @override
  State<SelectClientsBottomSheet> createState() =>
      _SelectClientsBottomSheetState();
}

class _SelectClientsBottomSheetState extends State<SelectClientsBottomSheet> {
  List<String> localFilterClients = [];
  final SaleController _saleController = Get.find();

  @override
  void initState() {
    localFilterClients = [..._saleController.filterClients];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ClientController clientController = Get.find();
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'clients'.tr,
                  style: h5(Theme.of(context).textTheme.bodyLarge!.color),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.close,
                    color: iconGrayColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ShaderMask(
              shaderCallback: (Rect rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.purple,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.purple
                  ],
                  stops: [
                    0.0,
                    0.05,
                    0.9,
                    1.0
                  ], // 10% purple, 80% transparent, 10% purple
                ).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: clientController.clients.length,
                itemBuilder: (_, index) {
                  return CheckboxListTile(
                    visualDensity: VisualDensity.compact,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Preferences.getTheme()
                        ? primaryLightColor
                        : primaryColor,
                    title: Text(
                      clientController.clients[index].name,
                    ),
                    value: localFilterClients
                        .contains(clientController.clients[index].id),
                    onChanged: (value) {
                      setState(
                        () {
                          if (localFilterClients
                              .contains(clientController.clients[index].id)) {
                            localFilterClients.remove(
                              clientController.clients[index].id,
                            );
                          } else {
                            localFilterClients
                                .add(clientController.clients[index].id);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Preferences.getTheme() ? lightGrayColor : borderColor,
                ),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: SecondaryButton(
                    onPressed: () {
                      _saleController.filterClients.clear();
                      _saleController.filterSales();
                      Navigator.pop(context);
                    },
                    text: 'reset'.tr,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    text: 'apply'.tr,
                    onPressed: () {
                      _saleController.setFilterClients(localFilterClients);
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

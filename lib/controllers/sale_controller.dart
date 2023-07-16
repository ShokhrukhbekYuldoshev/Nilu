import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/utils/constants.dart';
import '../models/sale_model.dart';
import '../services/firestore_db.dart';

class SaleController extends GetxController {
  @override
  void onInit() {
    try {
      sales.bindStream(FirestoreDb().getSales());
      filteredSales.value = sales;
      // ignore: empty_catches
    } catch (e) {}
    super.onInit();
  }

  // * CRUD
  final sales = <Sale>[].obs;
  final dates = [].obs;
  void deleteSale(Sale sale) {
    try {
      sales.remove(sale);
      firestore.collection('sales').doc(sale.id).delete();
      successSnackbar('Sale ${'deleted'.tr}');
    } catch (e) {
      errorSnackbar(e.toString());
    }
  }

  int getDatesCount() {
    return dates.length;
  }

  void setSalesByDate() {
    dates.value = [];
    for (var i = 0; i < filteredSales.length; i++) {
      DateTime date = filteredSales[i].date.toDate();
      date = DateUtils.dateOnly(date);

      if (dates.contains(date)) {
        continue;
      } else {
        dates.add(date);
      }
    }
    dates.sort((a, b) => b.compareTo(a));
  }

  double getTodaySales() {
    double todaysSales = 0;
    DateTime date = DateUtils.dateOnly(DateTime.now());
    for (var i = 0; i < sales.length; i++) {
      DateTime saleDate = DateUtils.dateOnly(sales[i].date.toDate());
      if (saleDate == date) {
        todaysSales += sales[i].price;
      }
    }
    return todaysSales;
  }

  double getTotalSales() {
    double totalSales = 0;
    for (var i = 0; i < sales.length; i++) {
      totalSales += sales[i].price;
    }
    return totalSales;
  }

  double getLastWeekSales() {
    double lastWeekSales = 0;
    var date =
        DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 7));
    var weekDay = date.weekday;
    var firstDayOfWeek = date.subtract(Duration(days: weekDay - 1));

    for (var i = 0; i < sales.length; i++) {
      DateTime saleDate = sales[i].date.toDate();
      if (saleDate.isAfter(firstDayOfWeek) &&
          saleDate.isBefore(firstDayOfWeek.add(const Duration(days: 7)))) {
        lastWeekSales += sales[i].price;
      }
    }
    return lastWeekSales;
  }

  double getLastMonthSales() {
    double lastMonthSales = 0;
    var date = DateUtils.dateOnly(DateTime.now());
    var firstDayOfMonth = DateTime(date.year, date.month - 1, 1);
    var lastDayOfMonth = DateTime(date.year, date.month, 1);

    for (var i = 0; i < sales.length; i++) {
      DateTime saleDate = sales[i].date.toDate();
      if (saleDate.isAfter(firstDayOfMonth) &&
          saleDate.isBefore(lastDayOfMonth)) {
        lastMonthSales += sales[i].price;
      }
    }
    return lastMonthSales;
  }

  double getLastYearSales() {
    double lastYearSales = 0;

    var date = DateUtils.dateOnly(DateTime.now());
    var firstDayOfYear = DateTime(date.year - 1, 1, 1);
    var lastDayOfYear = DateTime(date.year, 1, 1);

    for (var i = 0; i < sales.length; i++) {
      DateTime saleDate = sales[i].date.toDate();
      if (saleDate.isAfter(firstDayOfYear) &&
          saleDate.isBefore(lastDayOfYear)) {
        lastYearSales += sales[i].price;
      }
    }
    return lastYearSales;
  }

  List<Sale> getSalesByDate(DateTime date) {
    List<Sale> salesByDate = [];
    date = DateUtils.dateOnly(date);
    for (var i = 0; i < filteredSales.length; i++) {
      DateTime saleDate = DateUtils.dateOnly(filteredSales[i].date.toDate());
      if (saleDate == date) {
        salesByDate.add(filteredSales[i]);
      }
    }
    salesByDate.sort((a, b) => b.date.compareTo(a.date));
    return salesByDate;
  }

  getTotalSalesByDate(DateTime date) {
    double totalSalesByDate = 0;
    date = DateUtils.dateOnly(date);
    for (var i = 0; i < sales.length; i++) {
      DateTime saleDate = DateUtils.dateOnly(sales[i].date.toDate());
      if (saleDate == date) {
        totalSalesByDate += sales[i].price;
      }
    }
    return totalSalesByDate;
  }

  getTopProducts(String value) {
    var dateStart = DateUtils.dateOnly(DateTime.now());
    var dateEnd =
        DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 1));

    // * last week
    if (value == 'last_week'.tr) {
      var date =
          DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 7));
      var weekDay = date.weekday;
      dateStart = date.subtract(Duration(days: weekDay - 1));
      dateEnd = dateStart.add(const Duration(days: 7));
    }
    // * last month
    else if (value == 'last_month'.tr) {
      var date = DateUtils.dateOnly(DateTime.now());
      dateStart = DateTime(date.year, date.month - 1, 1);
      dateEnd = DateTime(date.year, date.month, 1);
    }
    // * last year
    else if (value == 'last_year'.tr) {
      var date = DateUtils.dateOnly(DateTime.now());
      dateStart = DateTime(date.year - 1, 1, 1);
      dateEnd = DateTime(date.year, 1, 1);
    }
    // * all time
    else if (value == 'all_time'.tr) {
      dateStart = DateTime(0, 0, 0);
      dateEnd = DateTime(3000, 0, 0);
    }

    List products = [];
    List productIds = [];
    for (var sale in sales) {
      if (sale.date.toDate().isAfter(dateStart) &&
          sale.date.toDate().isBefore(dateEnd)) {
        for (var product in sale.products) {
          if (!productIds.contains(product['id'])) {
            productIds.add(product['id']);
            products.add(Map.from(product));
          } else {
            for (var i = 0; i < products.length; i++) {
              if (products[i]['id'] == product['id']) {
                products[i]['price'] =
                    ((product['price'] * product['quantity']) +
                            (products[i]['price'] * products[i]['quantity'])) /
                        (products[i]['quantity'] + product['quantity']);
                products[i]['quantity'] += product['quantity'];
              }
            }
          }
        }
      }
    }
    products.sort((a, b) => b['quantity']!.compareTo(a['quantity']!));
    return products;
  }

  // * FILTERING
  DateTimeRange? selectedDateRange;
  final filteredSales = <Sale>[].obs;
  final saleType = 'All'.obs;
  final filterClients = <String>[].obs;

  void filterSales() {
    filteredSales.value = sales;
    if (selectedDateRange != null) {
      filteredSales.value = filteredSales.where((sale) {
        return sale.date.toDate().isAfter(selectedDateRange!.start) &&
            sale.date
                .toDate()
                .isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    if (filterClients.isNotEmpty) {
      filteredSales.value = filteredSales.where((sale) {
        return filterClients.contains(sale.client);
      }).toList();
    }
    if (saleType.value == 'Debt') {
      filteredSales.value = filteredSales.where((sale) {
        return sale.debt > 0;
      }).toList();
    }

    setSalesByDate();
  }

  void setSaleType(String type) {
    saleType.value = type;
    filterSales();
  }

  void setFilterClients(List<String> clients) {
    filterClients.value = clients;
    filterSales();
  }

  void setSelectedDateRange(DateTimeRange dateRange) {
    selectedDateRange = dateRange;
    filterSales();
  }

  void clearSelectedDateRange() {
    selectedDateRange = null;
  }
}

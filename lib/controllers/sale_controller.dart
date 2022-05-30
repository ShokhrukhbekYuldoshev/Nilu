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
      successSnackbar('Sale deleted');
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

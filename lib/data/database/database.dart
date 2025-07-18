import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gizmoglobe_client/enums/product_related/mainboard_enums/mainboard_compatibility.dart';
import 'package:gizmoglobe_client/objects/address_related/address.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/voucher_related/owned_voucher.dart';

import '../../enums/manufacturer/manufacturer_status.dart';
import '../../enums/product_related/category_enum.dart';
import '../../enums/product_related/cpu_enums/cpu_family.dart';
import '../../enums/product_related/drive_enums/drive_capacity.dart';
import '../../enums/product_related/drive_enums/drive_type.dart';
import '../../enums/product_related/gpu_enums/gpu_bus.dart';
import '../../enums/product_related/gpu_enums/gpu_capacity.dart';
import '../../enums/product_related/gpu_enums/gpu_series.dart';
import '../../enums/product_related/mainboard_enums/mainboard_form_factor.dart';
import '../../enums/product_related/mainboard_enums/mainboard_series.dart';
import '../../enums/product_related/product_status_enum.dart';
import '../../enums/product_related/psu_enums/psu_efficiency.dart';
import '../../enums/product_related/psu_enums/psu_modular.dart';
import '../../enums/product_related/ram_enums/ram_bus.dart';
import '../../enums/product_related/ram_enums/ram_capacity_enum.dart';
import '../../enums/product_related/ram_enums/ram_type.dart';
import '../../enums/voucher_related/voucher_status.dart';
import '../../objects/address_related/province.dart';
import '../../objects/product_related/product_factory.dart';
import '../../objects/voucher_related/voucher.dart';
import '../firebase/firebase.dart';

class Database {
  static final Database _database = Database._internal();

  String userID = '';
  String username = '';
  String email = '';

  List<Manufacturer> manufacturerList = [];
  List<Manufacturer> inactiveManufacturerList = [];
  List<Product> productList = [];
  List<Product> fullProductList = []; // Full product list for sales orders
  List<Province> provinceList = [];
  List<Address> addressList = [];
  List<Product> favoriteProducts = [];
  List<Product> bestSellerProducts = [];
  List<SalesInvoice> salesInvoiceList = [];
  List<Voucher> allVoucherList = [];
  List<OwnedVoucher> ownedVoucherList = [];

  // Add these properties to store voucher lists
  List<Voucher> userVouchers = [];
  List<Voucher> ongoingVouchers = [];
  List<Voucher> upcomingVouchers = [];


  // final List<Map<String, dynamic>> voucherDataList = [
  //   {
  //     'voucherID': 'voucher1',
  //     'voucherName': 'Discount 10%',
  //     'startTime': DateTime(2025, 5, 1),
  //     'discountValue': 10.0,
  //     'minimumPurchase': 0.0,
  //     'maxUsagePerPerson': 1,
  //     'isVisible': true,
  //     'isEnabled': true,
  //     'description': '',
  //     'hasEndTime': true,
  //     'endTime': DateTime(2025, 5, 31),
  //     'isLimited': true,
  //     'maximumUsage': 100,
  //     'usageLeft': 0,
  //     'isPercentage': true,
  //     'maximumDiscountValue': 100.0,
  //   },
  //   {
  //     'voucherID': 'voucher2',
  //     'voucherName': 'Discount \$20',
  //     'startTime': DateTime(2025, 6, 1),
  //     'discountValue': 20.0,
  //     'minimumPurchase': 50.0,
  //     'maxUsagePerPerson': 1,
  //     'isVisible': false,
  //     'isEnabled': false,
  //     'description': '\$20 off orders over \$50',
  //     'hasEndTime': true,
  //     'endTime': DateTime(2025, 6, 30),
  //     'isLimited': false,
  //     'isPercentage': false,
  //   },
  //   {
  //     'voucherID': 'voucher3',
  //     'voucherName': 'Discount 30%',
  //     'startTime': DateTime(2025, 5, 1),
  //     'discountValue': 30.0,
  //     'minimumPurchase': 0.0,
  //     'maxUsagePerPerson': 1,
  //     'isVisible': true,
  //     'isEnabled': true,
  //     'description': '30% off, up to \$100',
  //     'hasEndTime': false,
  //     'isLimited': true,
  //     'maximumUsage': 50,
  //     'usageLeft': 10,
  //     'isPercentage': true,
  //     'maximumDiscountValue': 100.0,
  //   },
  //   {
  //     'voucherID': 'voucher4',
  //     'voucherName': 'Discount \$50',
  //     'startTime': DateTime(2025, 6, 1),
  //     'discountValue': 50.0,
  //     'minimumPurchase': 100.0,
  //     'maxUsagePerPerson': 1,
  //     'isVisible': false,
  //     'isEnabled': true,
  //     'description': '\$50 off orders over \$100',
  //     'hasEndTime': false,
  //     'isLimited': true,
  //     'maximumUsage': 5,
  //     'usageLeft': 5,
  //     'isPercentage': false,
  //   },
  //   {
  //     'voucherID': 'voucher5',
  //     'voucherName': 'Discount 15%',
  //     'startTime': DateTime(2025, 4, 1),
  //     'discountValue': 15.0,
  //     'minimumPurchase': 0.0,
  //     'maxUsagePerPerson': 1,
  //     'isVisible': true,
  //     'isEnabled': true,
  //     'description': '15% off, up to \$100',
  //     'hasEndTime': true,
  //     'endTime': DateTime(2025, 4, 30),
  //     'isLimited': true,
  //     'maximumUsage': 5,
  //     'usageLeft': 5,
  //     'isPercentage': true,
  //     'maximumDiscountValue': 100.0,
  //   },
  // ];

  factory Database() {
    return _database;
  }

  Database._internal();

  Future<String?> getCurrentUserID() async {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  void getInactiveManufacturerList() {
    inactiveManufacturerList = manufacturerList
        .where((manufacturer) => manufacturer.status == ManufacturerStatus.inactive)
        .toList();
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      await getUserData();
      if (kDebugMode) {
        print('Getting data from Firebase');
      }

      // print('Đang lấy dữ liệu từ Firebase');
      provinceList = await fetchProvinces();

      await fetchAddress();

      final manufacturerSnapshot = await FirebaseFirestore.instance.collection('manufacturers').get();

      manufacturerList = manufacturerSnapshot.docs.map((doc) {
        final data = doc.data();
        final docStatus = data['status'] as String?;
        return Manufacturer(
          manufacturerID: doc.id,
          manufacturerName: doc['manufacturerName'] as String,
          status: ManufacturerStatus.values.firstWhere(
            (e) => e.getName().toLowerCase() == (docStatus?.toLowerCase() ?? ManufacturerStatus.active.getName().toLowerCase()),
            orElse: () => ManufacturerStatus.active,
          ),
        );
      }).toList();

      getInactiveManufacturerList();

      // Get all products from Firestore for the fullProductList (for sales orders)
      final fullProductSnapshot = await FirebaseFirestore.instance.collection('products').get();

      // Process all products for the fullProductList without filtering out inactive manufacturers' products
      fullProductList = await Future.wait(fullProductSnapshot.docs.map((doc) async {
        try {
          final data = doc.data();

          // Tìm manufacturer tương ứng
          final manufacturer = manufacturerList.firstWhere(
                (m) => m.manufacturerID == data['manufacturerID'],
            orElse: () {
              if (kDebugMode) {
                print('Manufacturer not found for product ${doc.id}');
              }
              // print('Không tìm thấy nhà sản xuất cho sản phẩm ${doc.id}');
              throw Exception('Manufacturer not found for product ${doc.id}');
              // throw Exception('Không tìm thấy nhà sản xuất cho sản phẩm ${doc.id}');
            },
          );

          // Chuyển đổi dữ liệu từ Firestore sang enum
          final category = CategoryEnum.values.firstWhere(
                (c) => c.getName() == data['category'],
            orElse: () {
              if (kDebugMode) {
                print('Invalid category for product ${doc.id}');
              }
              // print('Danh mục không hợp lệ cho sản phẩm ${doc.id}');
              throw Exception('Invalid category for product ${doc.id}');
              // throw Exception('Danh mục không hợp lệ cho sản phẩm ${doc.id}');
            },
          );

          final specificData = _getSpecificProductData(data, category);
          if (specificData.isEmpty) {
            if (kDebugMode) {
              print('Cannot get specific data for product ${doc.id}');
            }
            // print('Không thể lấy dữ liệu cụ thể cho sản phẩm ${doc.id}');
            throw Exception('Cannot get specific data for product ${doc.id}');
            // throw Exception('Không thể lấy dữ liệu cụ thể cho sản phẩm ${doc.id}');
          }

          return ProductFactory.createProduct(
            category,
            {
              'productID': doc.id,
              'productName': data['productName'] as String,
              'price': (data['sellingPrice'] as num).toDouble(),
              'discount': (data['discount'] as num?)?.toDouble() ?? 0.0,
              'release': (data['release'] as Timestamp).toDate(),
              'sales': data['sales'] as int,
              'stock': data['stock'] as int,
              'enDescription': data['enDescription'] as String?,
              'viDescription': data['viDescription'] as String?,
              'imageUrl': data['imageUrl'] as String?,
              'status': ProductStatusEnum.values.firstWhere(
                    (s) => s.getName() == data['status'],
                orElse: () {
                  if (kDebugMode) {
                    print('Invalid status for product ${doc.id}');
                  }
                  // print('Trạng thái không hợp lệ cho sản phẩm ${doc.id}');
                  throw Exception('Invalid status for product ${doc.id}');
                  // throw Exception('Trạng thái không hợp lệ cho sản phẩm ${doc.id}');
                },
              ),
              'manufacturer': manufacturer,
              ...specificData,
            },
          );
        } catch (e) {
          if (kDebugMode) {
            print('Error processing product ${doc.id}: $e');
          }
          // print('Lỗi xử lý sản phẩm ${doc.id}: $e');
          return Future.error('Error processing product ${doc.id}: $e');
          // return Future.error('Lỗi xử lý sản phẩm ${doc.id}: $e');
        }
      }));

      if (kDebugMode) {
        print('Loaded ${fullProductList.length} products for fullProductList (sales orders)');
      }

      // Lấy danh sách products từ Firestore for regular productList
      final productSnapshot = await FirebaseFirestore.instance.collection('products').get();

      // print('Số lượng products trong snapshot: ${productSnapshot.docs.length}');

      productList = await Future.wait(productSnapshot.docs.map((doc) async {
        try {
          final data = doc.data();

          // Tìm manufacturer tương ứng
          final manufacturer = manufacturerList.firstWhere(
            (m) => m.manufacturerID == data['manufacturerID'],
            orElse: () {
              if (kDebugMode) {
                print('Manufacturer not found for product ${doc.id}');
              }
              // print('Không tìm thấy nhà sản xuất cho sản phẩm ${doc.id}');
              throw Exception('Manufacturer not found for product ${doc.id}');
              // throw Exception('Không tìm thấy nhà sản xuất cho sản phẩm ${doc.id}');
            },
          );

          // Skip products from inactive manufacturers
          if (inactiveManufacturerList.any((m) => m.manufacturerID == manufacturer.manufacturerID)) {
            if (kDebugMode) {
              print('Skipping product ${doc.id} from inactive manufacturer ${manufacturer.manufacturerName}');
            }
            return null;
          }

          // Get product status first to check if it's active
          final productStatus = ProductStatusEnum.values.firstWhere(
            (s) => s.getName() == data['status'],
            orElse: () {
              if (kDebugMode) {
                print('Invalid status for product ${doc.id}');
              }
              // print('Trạng thái không hợp lệ cho sản phẩm ${doc.id}');
              throw Exception('Invalid status for product ${doc.id}');
              // throw Exception('Trạng thái không hợp lệ cho sản phẩm ${doc.id}');
            },
          );

          // Skip products that are not active
          if (productStatus != ProductStatusEnum.active) {
            if (kDebugMode) {
              print('Skipping product ${doc.id} with non-active status: ${productStatus.getName()}');
            }
            return null;
          }

          // Chuyển đổi dữ liệu từ Firestore sang enum
          final category = CategoryEnum.values.firstWhere(
            (c) => c.getName() == data['category'],
            orElse: () {
              if (kDebugMode) {
                print('Invalid category for product ${doc.id}');
              }
              // print('Danh mục không hợp lệ cho sản phẩm ${doc.id}');
              throw Exception('Invalid category for product ${doc.id}');
              // throw Exception('Danh mục không hợp lệ cho sản phẩm ${doc.id}');
            },
          );

          final specificData = _getSpecificProductData(data, category);
          if (specificData.isEmpty) {
            if (kDebugMode) {
              print('Cannot get specific data for product ${doc.id}');
            }
            // print('Không thể lấy dữ liệu cụ thể cho sản phẩm ${doc.id}');
            throw Exception('Cannot get specific data for product ${doc.id}');
            // throw Exception('Không thể lấy dữ liệu cụ thể cho sản phẩm ${doc.id}');
          }

          return ProductFactory.createProduct(
            category,
            {
              'productID': doc.id,
              'productName': data['productName'] as String,
              'price': (data['sellingPrice'] as num).toDouble(),
              'discount': (data['discount'] as num?)?.toDouble() ?? 0.0,
              'release': (data['release'] as Timestamp).toDate(),
              'sales': data['sales'] as int,
              'stock': data['stock'] as int,
              'enDescription': data['enDescription'] as String?,
              'viDescription': data['viDescription'] as String?,
              'imageUrl': data['imageUrl'] as String?,
              'status': productStatus,
              'manufacturer': manufacturer,
              ...specificData,
            },
          );
        } catch (e) {
          if (kDebugMode) {
            print('Error processing product ${doc.id}: $e');
          }
          // print('Lỗi xử lý sản phẩm ${doc.id}: $e');
          return Future.error('Error processing product ${doc.id}: $e');
          // return Future.error('Lỗi xử lý sản phẩm ${doc.id}: $e');
        }
      })).then((products) => products.where((product) => product != null).cast<Product>().toList());

      // print('Số lượng products trong list: ${productList.length}');

      bestSellerProducts = fetchBestSellerProducts();
      favoriteProducts = await fetchFavoriteProducts(userID);

      allVoucherList = await Firebase().getVouchers();

      await fetchSalesInvoice();
    } catch (e) {
      if (kDebugMode) {
        print('Fetching data error: $e');
      }
      // print('Lỗi khi lấy dữ liệu: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _getSpecificProductData(
      Map<String, dynamic> data, CategoryEnum category) {
    switch (category) {
      case CategoryEnum.ram:
        return {
          'bus': RAMBus.values.firstWhere((b) => b.getName() == data['bus']),
          'capacity': RAMCapacity.values
              .firstWhere((c) => c.getName() == data['capacity']),
          'ramType':
              RAMType.values.firstWhere((t) => t.getName() == data['ramType']),
        };

      case CategoryEnum.cpu:
        return {
          'family':
              CPUFamily.values.firstWhere((f) => f.getName() == data['family']),
          'core': data['core'],
          'thread': data['thread'],
          'clockSpeed': data['clockSpeed'].toDouble(),
        };
      case CategoryEnum.gpu:
        return {
          'series':
              GPUSeries.values.firstWhere((s) => s.getName() == data['series']),
          'capacity': GPUCapacity.values
              .firstWhere((c) => c.getName() == data['capacity']),
          'busWidth':
              GPUBus.values.firstWhere((b) => b.getName() == data['busWidth']),
          'clockSpeed': (data['clockSpeed'] as num).toDouble(),
        };
      case CategoryEnum.mainboard:
        return {
          'formFactor': MainboardFormFactor.values
              .firstWhere((f) => f.getName() == data['formFactor']),
          'series': MainboardSeries.values
              .firstWhere((s) => s.getName() == data['series']),
          'compatibility': MainboardCompatibility.values
              .firstWhere((c) => c.getName() == data['compatibility']),
        };
      case CategoryEnum.drive:
        return {
          'type':
              DriveType.values.firstWhere((t) => t.getName() == data['type']),
          'capacity': DriveCapacity.values
              .firstWhere((c) => c.getName() == data['capacity']),
        };
      case CategoryEnum.psu:
        return {
          'wattage': data['wattage'],
          'efficiency': PSUEfficiency.values
              .firstWhere((e) => e.getName() == data['efficiency']),
          'modular': PSUModular.values
              .firstWhere((m) => m.getName() == data['modular']),
        };
    }
  }

  Future<void> initialize() async {
    try {
      await fetchDataFromFirestore();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing connection to Firebase: $e');
      }
      // print('Lỗi khi khởi tạo kết nối tới Firebase: $e');
      // Nếu không lấy được dữ liệu từ Firestore, sử dụng dữ liệu mẫu
      // _initializeSampleData();
    }
  }

  // Future<void> _initializeSampleData() async {
  //   manufacturerList = [
  //     const Manufacturer(
  //       manufacturerID: 'Corsair',
  //       manufacturerName: 'Corsair',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'G.Skill',
  //       manufacturerName: 'G.Skill',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Crucial',
  //       manufacturerName: 'Crucial',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Kingston',
  //       manufacturerName: 'Kingston',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Intel',
  //       manufacturerName: 'Intel',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'AMD',
  //       manufacturerName: 'AMD',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'ASUS',
  //       manufacturerName: 'ASUS',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'MSI',
  //       manufacturerName: 'MSI',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Gigabyte',
  //       manufacturerName: 'Gigabyte',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Samsung',
  //       manufacturerName: 'Samsung',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Western Digital',
  //       manufacturerName: 'Western Digital',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Seagate',
  //       manufacturerName: 'Seagate',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Seasonic',
  //       manufacturerName: 'Seasonic',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'be quiet!',
  //       manufacturerName: 'be quiet!',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Thermaltake',
  //       manufacturerName: 'Thermaltake',
  //     ),
  //   ];
  //   productList = [
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'Kingston HyperX Fury DDR3',
  //       'price': 49.99,
  //       'manufacturer': manufacturerList[3], // Kingston
  //       'bus': RAMBus.mhz1600,
  //       'capacity': RAMCapacity.gb8,
  //       'ramType': RAMType.ddr3,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'Corsair Vengeance DDR3',
  //       'price': 89.99,
  //       'manufacturer': manufacturerList[0], // Corsair
  //       'bus': RAMBus.mhz2133,
  //       'capacity': RAMCapacity.gb16,
  //       'ramType': RAMType.ddr3,
  //     }),
  //
  //     // DDR4 RAM samples
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'G.Skill Ripjaws V DDR4',
  //       'price': 69.99,
  //       'manufacturer': manufacturerList[1], // G.Skill
  //       'bus': RAMBus.mhz2400,
  //       'capacity': RAMCapacity.gb16,
  //       'ramType': RAMType.ddr4,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'Crucial Ballistix DDR4',
  //       'price': 129.99,
  //       'manufacturer': manufacturerList[2], // Crucial
  //       'bus': RAMBus.mhz3200,
  //       'capacity': RAMCapacity.gb32,
  //       'ramType': RAMType.ddr4,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'Corsair Dominator DDR4',
  //       'price': 249.99,
  //       'manufacturer': manufacturerList[0], // Corsair
  //       'bus': RAMBus.mhz3200,
  //       'capacity': RAMCapacity.gb64,
  //       'ramType': RAMType.ddr4,
  //     }),
  //
  //     // DDR5 RAM samples
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'G.Skill Trident Z5 DDR5',
  //       'price': 159.99,
  //       'manufacturer': manufacturerList[1], // G.Skill
  //       'bus': RAMBus.mhz4800,
  //       'capacity': RAMCapacity.gb32,
  //       'ramType': RAMType.ddr5,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'Corsair Vengeance DDR5',
  //       'price': 299.99,
  //       'manufacturer': manufacturerList[0], // Corsair
  //       'bus': RAMBus.mhz4800,
  //       'capacity': RAMCapacity.gb64,
  //       'ramType': RAMType.ddr5,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'Kingston Fury Beast DDR5',
  //       'price': 599.99,
  //       'manufacturer': manufacturerList[3], // Kingston
  //       'bus': RAMBus.mhz4800,
  //       'capacity': RAMCapacity.gb128,
  //       'ramType': RAMType.ddr5,
  //     }),
  //
  //     // CPU samples
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'Intel Core i3-13100',
  //       'price': 149.99,
  //       'manufacturer': manufacturerList[4], // Intel
  //       'family': CPUFamily.corei3Ultra3,
  //       'core': 4,
  //       'thread': 8,
  //       'clockSpeed': 3.4,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'Intel Core i5-13600K',
  //       'price': 319.99,
  //       'manufacturer': manufacturerList[4], // Intel
  //       'family': CPUFamily.corei5Ultra5,
  //       'core': 14,
  //       'thread': 20,
  //       'clockSpeed': 3.5,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'Intel Core i7-13700K',
  //       'price': 419.99,
  //       'manufacturer': manufacturerList[4], // Intel
  //       'family': CPUFamily.corei7Ultra7,
  //       'core': 16,
  //       'thread': 24,
  //       'clockSpeed': 3.4,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'Intel Xeon W-3475X',
  //       'price': 1499.99,
  //       'manufacturer': manufacturerList[4], // Intel
  //       'family': CPUFamily.xeon,
  //       'core': 36,
  //       'thread': 72,
  //       'clockSpeed': 2.8,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'AMD Ryzen 3 4100',
  //       'price': 99.99,
  //       'manufacturer': manufacturerList[5], // AMD
  //       'family': CPUFamily.ryzen3,
  //       'core': 4,
  //       'thread': 8,
  //       'clockSpeed': 3.8,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'AMD Ryzen 5 7600X',
  //       'price': 299.99,
  //       'manufacturer': manufacturerList[5], // AMD
  //       'family': CPUFamily.ryzen5,
  //       'core': 6,
  //       'thread': 12,
  //       'clockSpeed': 4.7,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'AMD Ryzen 7 7800X3D',
  //       'price': 449.99,
  //       'manufacturer': manufacturerList[5], // AMD
  //       'family': CPUFamily.ryzen7,
  //       'core': 8,
  //       'thread': 16,
  //       'clockSpeed': 4.2,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'AMD Threadripper PRO 5995WX',
  //       'price': 6499.99,
  //       'manufacturer': manufacturerList[5], // AMD
  //       'family': CPUFamily.threadripper,
  //       'core': 64,
  //       'thread': 128,
  //       'clockSpeed': 2.7,
  //     }),
  //
  //     // GPU samples
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'ASUS ROG STRIX GTX 1660 SUPER',
  //       'price': 299.99,
  //       'manufacturer': manufacturerList[6], // ASUS
  //       'series': GPUSeries.gtx,
  //       'capacity': GPUCapacity.gb6,
  //       'busWidth': GPUBus.bit128,
  //       'clockSpeed': 1.53,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'MSI Gaming X RTX 4070',
  //       'price': 599.99,
  //       'manufacturer': manufacturerList[7], // MSI
  //       'series': GPUSeries.rtx,
  //       'capacity': GPUCapacity.gb12,
  //       'busWidth': GPUBus.bit128,
  //       'clockSpeed': 2.31,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'NVIDIA Quadro RTX A6000',
  //       'price': 4499.99,
  //       'manufacturer': manufacturerList[6], // ASUS
  //       'series': GPUSeries.quadro,
  //       'capacity': GPUCapacity.gb24,
  //       'busWidth': GPUBus.bit384,
  //       'clockSpeed': 1.80,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'Gigabyte RX 7900 XTX',
  //       'price': 999.99,
  //       'manufacturer': manufacturerList[8], // Gigabyte
  //       'series': GPUSeries.rx,
  //       'capacity': GPUCapacity.gb24,
  //       'busWidth': GPUBus.bit384,
  //       'clockSpeed': 2.50,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'AMD FirePro W9100',
  //       'price': 3999.99,
  //       'manufacturer': manufacturerList[5], // AMD
  //       'series': GPUSeries.firePro,
  //       'capacity': GPUCapacity.gb16,
  //       'busWidth': GPUBus.bit512,
  //       'clockSpeed': 0.93,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'Intel Arc A770',
  //       'price': 349.99,
  //       'manufacturer': manufacturerList[4], // Intel
  //       'series': GPUSeries.arc,
  //       'capacity': GPUCapacity.gb16,
  //       'busWidth': GPUBus.bit256,
  //       'clockSpeed': 2.10,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'MSI Gaming X RTX 4090',
  //       'price': 1999.99,
  //       'manufacturer': manufacturerList[7], // MSI
  //       'series': GPUSeries.rtx,
  //       'capacity': GPUCapacity.gb24,
  //       'busWidth': GPUBus.bit384,
  //       'clockSpeed': 2.52,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'Gigabyte RX 6600',
  //       'price': 249.99,
  //       'manufacturer': manufacturerList[8], // Gigabyte
  //       'series': GPUSeries.rx,
  //       'capacity': GPUCapacity.gb8,
  //       'busWidth': GPUBus.bit128,
  //       'clockSpeed': 2.49,
  //     }),
  //
  //     // Mainboard samples
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'ASUS PRIME H610M-K',
  //       'price': 89.99,
  //       'manufacturer': manufacturerList[6], // ASUS
  //       'formFactor': MainboardFormFactor.microATX,
  //       'series': MainboardSeries.h,
  //       'compatibility': MainboardCompatibility.intel,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'MSI PRO H610I',
  //       'price': 119.99,
  //       'manufacturer': manufacturerList[7], // MSI
  //       'formFactor': MainboardFormFactor.miniITX,
  //       'series': MainboardSeries.h,
  //       'compatibility': MainboardCompatibility.intel,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'Gigabyte B650 AORUS ELITE AX',
  //       'price': 229.99,
  //       'manufacturer': manufacturerList[8], // Gigabyte
  //       'formFactor': MainboardFormFactor.atx,
  //       'series': MainboardSeries.b,
  //       'compatibility': MainboardCompatibility.amd,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'MSI MAG B760M MORTAR',
  //       'price': 179.99,
  //       'manufacturer': manufacturerList[7], // MSI
  //       'formFactor': MainboardFormFactor.microATX,
  //       'series': MainboardSeries.b,
  //       'compatibility': MainboardCompatibility.intel,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'ASUS ROG STRIX B650E-I',
  //       'price': 289.99,
  //       'manufacturer': manufacturerList[6], // ASUS
  //       'formFactor': MainboardFormFactor.miniITX,
  //       'series': MainboardSeries.b,
  //       'compatibility': MainboardCompatibility.amd,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'ASUS ROG MAXIMUS Z790 HERO',
  //       'price': 629.99,
  //       'manufacturer': manufacturerList[6], // ASUS
  //       'formFactor': MainboardFormFactor.atx,
  //       'series': MainboardSeries.z,
  //       'compatibility': MainboardCompatibility.intel,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'MSI MPG Z790M EDGE',
  //       'price': 399.99,
  //       'manufacturer': manufacturerList[7], // MSI
  //       'formFactor': MainboardFormFactor.microATX,
  //       'series': MainboardSeries.z,
  //       'compatibility': MainboardCompatibility.intel,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'Gigabyte X670E AORUS MASTER',
  //       'price': 499.99,
  //       'manufacturer': manufacturerList[8], // Gigabyte
  //       'formFactor': MainboardFormFactor.atx,
  //       'series': MainboardSeries.x,
  //       'compatibility': MainboardCompatibility.amd,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'ASUS ROG STRIX X670E-I',
  //       'price': 469.99,
  //       'manufacturer': manufacturerList[6], // ASUS
  //       'formFactor': MainboardFormFactor.miniITX,
  //       'series': MainboardSeries.x,
  //       'compatibility': MainboardCompatibility.amd,
  //     }),
  //
  //     // Drive samples
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Seagate Barracuda',
  //       'price': 49.99,
  //       'manufacturer': manufacturerList[11], // Seagate
  //       'type': DriveType.hdd,
  //       'capacity': DriveCapacity.tb2,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'WD Blue HDD',
  //       'price': 89.99,
  //       'manufacturer': manufacturerList[10], // Western Digital
  //       'type': DriveType.hdd,
  //       'capacity': DriveCapacity.tb4,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Samsung 870 EVO',
  //       'price': 69.99,
  //       'manufacturer': manufacturerList[9], // Samsung
  //       'type': DriveType.sataSSD,
  //       'capacity': DriveCapacity.gb512,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Crucial MX500',
  //       'price': 89.99,
  //       'manufacturer': manufacturerList[2], // Crucial
  //       'type': DriveType.sataSSD,
  //       'capacity': DriveCapacity.tb1,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'WD Blue SATA SSD',
  //       'price': 159.99,
  //       'manufacturer': manufacturerList[10], // Western Digital
  //       'type': DriveType.sataSSD,
  //       'capacity': DriveCapacity.tb2,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Samsung 860 EVO M.2',
  //       'price': 79.99,
  //       'manufacturer': manufacturerList[9], // Samsung
  //       'type': DriveType.m2NGFF,
  //       'capacity': DriveCapacity.gb512,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'WD Blue M.2 SATA',
  //       'price': 109.99,
  //       'manufacturer': manufacturerList[10], // Western Digital
  //       'type': DriveType.m2NGFF,
  //       'capacity': DriveCapacity.tb1,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Samsung 970 EVO Plus',
  //       'price': 119.99,
  //       'manufacturer': manufacturerList[9], // Samsung
  //       'type': DriveType.m2NVME,
  //       'capacity': DriveCapacity.gb512,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'WD Black SN850X',
  //       'price': 159.99,
  //       'manufacturer': manufacturerList[10], // Western Digital
  //       'type': DriveType.m2NVME,
  //       'capacity': DriveCapacity.tb1,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Seagate FireCuda 530',
  //       'price': 359.99,
  //       'manufacturer': manufacturerList[11], // Seagate
  //       'type': DriveType.m2NVME,
  //       'capacity': DriveCapacity.tb2,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Corsair Force MP600',
  //       'price': 699.99,
  //       'manufacturer': manufacturerList[0], // Corsair
  //       'type': DriveType.m2NVME,
  //       'capacity': DriveCapacity.tb4,
  //     }),
  //
  //     // PSU samples
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'Thermaltake Smart 500W',
  //       'price': 44.99,
  //       'manufacturer': manufacturerList[14], // Thermaltake
  //       'wattage': 500,
  //       'efficiency': PSUEfficiency.white,
  //       'modular': PSUModular.nonModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'Corsair CV650',
  //       'price': 69.99,
  //       'manufacturer': manufacturerList[0], // Corsair
  //       'wattage': 650,
  //       'efficiency': PSUEfficiency.bronze,
  //       'modular': PSUModular.nonModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'be quiet! Pure Power 11',
  //       'price': 89.99,
  //       'manufacturer': manufacturerList[13], // be quiet!
  //       'wattage': 600,
  //       'efficiency': PSUEfficiency.bronze,
  //       'modular': PSUModular.semiModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'Seasonic FOCUS GX-750',
  //       'price': 129.99,
  //       'manufacturer': manufacturerList[12], // Seasonic
  //       'wattage': 750,
  //       'efficiency': PSUEfficiency.gold,
  //       'modular': PSUModular.fullModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'Corsair RM850x',
  //       'price': 149.99,
  //       'manufacturer': manufacturerList[0], // Corsair
  //       'wattage': 850,
  //       'efficiency': PSUEfficiency.gold,
  //       'modular': PSUModular.fullModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'be quiet! Straight Power 11',
  //       'price': 189.99,
  //       'manufacturer': manufacturerList[13], // be quiet!
  //       'wattage': 850,
  //       'efficiency': PSUEfficiency.platinum,
  //       'modular': PSUModular.fullModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'Seasonic PRIME TX-1000',
  //       'price': 309.99,
  //       'manufacturer': manufacturerList[12], // Seasonic
  //       'wattage': 1000,
  //       'efficiency': PSUEfficiency.titanium,
  //       'modular': PSUModular.fullModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'be quiet! Dark Power Pro 12',
  //       'price': 399.99,
  //       'manufacturer': manufacturerList[13], // be quiet!
  //       'wattage': 1200,
  //       'efficiency': PSUEfficiency.titanium,
  //       'modular': PSUModular.fullModular,
  //     }),
  //   ];
  //   provinceList = await fetchProvinces();
  // }

  void generateSampleData() {
    // _initializeSampleData();
  }

  Future<List<Province>> fetchProvinces() async {
    const filePath = 'lib/data/database/full_json_generated_data_vn_units.json';

    try {
      final String response = await rootBundle.loadString(filePath);
      if (response.isEmpty) {
        if (kDebugMode) {
          print('JSON file is empty');
        }
        throw Exception('JSON file is empty');
        // throw Exception('Tệp JSON trống');
      }

      final List? jsonList = jsonDecode(response) as List<dynamic>?;
      if (jsonList == null) {
        if (kDebugMode) {
          print('Error parsing JSON data');
        }
        throw Exception('Error parsing JSON data');
        // throw Exception('Lỗi khi phân tích dữ liệu JSON');
      }

      List<Province> provinceList =
          jsonList.map((province) => Province.fromJson(province)).toList();
      return provinceList;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading provinces from file: $e');
      }
      throw Exception('Error loading provinces from file: $e');
      // throw Exception('Lỗi khi tải danh sách tỉnh thành từ tệp: $e');
    }
  }

  Future<void> getUsername() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      username = userDoc['username'];
    }
  }

  Future<void> getUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      userID = user.uid;
      username = userDoc['username'];
      email = userDoc['email'];
    }
  }

  Future<void> getUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      userID = user.uid;
      username = userDoc['username'];
      email = userDoc['email'];
    }

    await fetchAddress();
    await fetchSalesInvoice();
  }

  Future<void> fetchAddress() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final addressSnapshot = await FirebaseFirestore.instance
          .collection('addresses')
          .where('customerID', isEqualTo: user.uid)
          .get();

      addressList = addressSnapshot.docs.map((doc) {
        return Address.fromMap(doc.data());
      }).toList();
    }
  }

  List<Product> fetchBestSellerProducts() {
    try {
      // Use the local productList that's already been filtered for inactive manufacturers and non-active products
      if (productList.isEmpty) {
        if (kDebugMode) {
          print('Product list is empty, cannot determine best sellers');
        }
        return [];
      }

      // Create a copy of the list to avoid modifying the original
      List<Product> sortedProducts = [...productList];

      // Sort by sales in descending order
      sortedProducts.sort((a, b) => b.sales.compareTo(a.sales));

      // Take the top 5 best sellers
      List<Product> bestSellers = sortedProducts.take(5).toList();

      if (kDebugMode) {
        print('Found ${bestSellers.length} best selling products from local data');
      }

      return bestSellers;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating best seller products: $e');
      }
      rethrow;
    }
  }

  void updateProductList(List<Product> productList) {
    this.productList = productList;
  }

  Future<List<Product>> fetchFavoriteProducts(String customerID) async {
    try {
      if (productList.isEmpty) {
        if (kDebugMode) {
          print('Product list is empty, cannot fetch favorites');
        }
        return [];
      }

      final favoriteSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerID)
          .collection('favorites')
          .get();

      final favoriteProductIDs =
          favoriteSnapshot.docs.map((doc) => doc.id).toList();

      if (favoriteProductIDs.isEmpty) {
        return [];
      }

      List<Product> favoriteProducts = productList
          .where((product) => favoriteProductIDs.contains(product.productID))
          .toList();

      if (kDebugMode) {
        print('Found ${favoriteProducts.length} favorite products from local data');
      }

      return favoriteProducts;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching favorite products: $e');
      }
      rethrow;
    }
  }

  Future<void> updateVoucherLists() async {
    try {
      // Step 1: Get all vouchers
      List<Voucher> allVouchers = await Firebase().getVouchers();

      // Step 2: Get current user ID
      final userId = await getCurrentUserID();
      if (userId == null) {
        // If not logged in, set empty lists
        userVouchers = [];
        ongoingVouchers = [];
        upcomingVouchers = [];
        return;
      }

      // Step 3: Get owned vouchers - using a simpler query to avoid index issues
      List<OwnedVoucher> ownedVouchers =
          await Firebase().getOwnedVouchersByCustomerId(userId);

      // Step 4: Create maps for faster lookups
      Map<String, Voucher> voucherMap = {
        for (var voucher in allVouchers) voucher.voucherID!: voucher
      };

      Map<String, OwnedVoucher> ownedVoucherMap = {
        for (var ownedVoucher in ownedVouchers)
          ownedVoucher.voucherID: ownedVoucher
      };

      // Step 5: Identify owned vouchers to remove (invalid ones)
      List<Future<void>> removalOperations = [];
      Set<String> validOwnedVoucherIds = {};

      for (var ownedVoucher in ownedVouchers) {
        final voucher = voucherMap[ownedVoucher.voucherID];
        final isValid = voucher != null &&
            voucher.isEnabled &&
            voucher.voucherTimeStatus != VoucherTimeStatus.expired;

        if (isValid) {
          validOwnedVoucherIds.add(ownedVoucher.voucherID);
        } else if (ownedVoucher.ownedVoucherID != null) {
          removalOperations
              .add(Firebase().removeOwnedVoucher(ownedVoucher.ownedVoucherID!));
        }
      }

      // Step 6: Find vouchers eligible for claiming
      List<Future<void>> claimOperations = [];

      for (var voucher in allVouchers) {
        if (voucher.isVisible &&
            voucher.isEnabled &&
            voucher.voucherTimeStatus != VoucherTimeStatus.expired &&
            !voucher.voucherRanOut &&
            !validOwnedVoucherIds.contains(voucher.voucherID)) {
          OwnedVoucher newOwnedVoucher = OwnedVoucher(
            voucherID: voucher.voucherID!,
            customerID: userId,
            numberOfUses: voucher.maxUsagePerPerson,
          );

          claimOperations.add(Firebase().addOwnedVoucher(newOwnedVoucher));
          // Add to valid IDs since we're claiming it now
          validOwnedVoucherIds.add(voucher.voucherID!);
          // Add the new owned voucher to our map for later use
          ownedVoucherMap[voucher.voucherID!] = newOwnedVoucher;
        }
      }

      // Step 7: Execute all Firebase operations in parallel
      if (removalOperations.isNotEmpty || claimOperations.isNotEmpty) {
        await Future.wait([...removalOperations, ...claimOperations]);
      }

      // Step 8: Replace maxUsagePerPerson with numberOfUses for each voucher
      List<Voucher> tempVouchers = [];
      for (var voucher in allVouchers) {
        if (validOwnedVoucherIds.contains(voucher.voucherID)) {
          // Replace maxUsagePerPerson with the user's numberOfUses for this voucher
          final ownedVoucher = ownedVoucherMap[voucher.voucherID];
          if (ownedVoucher != null) {
            voucher.maxUsagePerPerson = ownedVoucher.numberOfUses;
          }
          // Only add vouchers with uses remaining
          if (voucher.maxUsagePerPerson > 0) {
            tempVouchers.add(voucher);
          }
        }
      }
      userVouchers = tempVouchers;

      // Step 9: Filter ongoing and upcoming vouchers
      ongoingVouchers = userVouchers
          .where((voucher) =>
              voucher.voucherTimeStatus == VoucherTimeStatus.ongoing)
          .toList();

      upcomingVouchers = userVouchers
          .where((voucher) =>
              voucher.voucherTimeStatus == VoucherTimeStatus.upcoming)
          .toList();

      // Sort all lists
      userVouchers.sort((a, b) => a.startTime.compareTo(b.startTime));
      ongoingVouchers.sort((a, b) => a.startTime.compareTo(b.startTime));
      upcomingVouchers.sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (e) {
      if (kDebugMode) {
        print('Error updating voucher lists: $e');
      }
      rethrow;
    }
  }

  // Get methods for voucher lists
  List<Voucher> getUserVouchers() => userVouchers;
  List<Voucher> getOngoingVouchers() => ongoingVouchers;
  List<Voucher> getUpcomingVouchers() => upcomingVouchers;

  Future<void> fetchSalesInvoice() async {
    salesInvoiceList = await Firebase().getSalesInvoices();
  }
}

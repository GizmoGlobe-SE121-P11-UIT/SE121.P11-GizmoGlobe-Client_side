import 'package:gizmoglobe_client/enums/product_related/cpu_enums/cpu_family.dart';

import '../../enums/product_related/category_enum.dart';
import 'product.dart';

class CPU extends Product {
  final CPUFamily family;
  final int core;
  final int thread;
  final double clockSpeed;

  CPU({
    required super.productName,
    required super.price,
    required super.manufacturer,
    required super.discount,
    required super.release,
    required super.stock,
    required super.sales,
    required super.status,
    super.category = CategoryEnum.cpu,
    required this.family,
    required this.core,
    required this.thread,
    required this.clockSpeed,
    super.enDescription,
    super.viDescription,
    super.imageUrl
  });
}
import 'package:gizmoglobe_client/enums/product_related/drive_enums/drive_capacity.dart';
import 'package:gizmoglobe_client/enums/product_related/drive_enums/drive_type.dart';

import '../../enums/product_related/category_enum.dart';
import 'product.dart';

class Drive extends Product {
  final DriveType type;
  final DriveCapacity capacity;

  Drive({
    required super.productName,
    required super.price,
    required super.manufacturer,
    required super.discount,
    required super.release,
    required super.sales,
    required super.stock,
    required super.status,
    super.category = CategoryEnum.drive,
    required this.type,
    required this.capacity,
    super.enDescription,
    super.viDescription,
    super.imageUrl,
  });
}
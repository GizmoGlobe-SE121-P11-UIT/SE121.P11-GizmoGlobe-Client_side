import 'package:gizmoglobe_client/enums/product_related/gpu_enums/gpu_bus.dart';
import 'package:gizmoglobe_client/enums/product_related/gpu_enums/gpu_capacity.dart';
import 'package:gizmoglobe_client/enums/product_related/gpu_enums/gpu_series.dart';

import '../../enums/product_related/category_enum.dart';
import 'product.dart';

class GPU extends Product {
  final GPUSeries series;
  final GPUCapacity capacity;
  final GPUBus bus;
  final double clockSpeed;

  GPU({
    required super.productName,
    required super.price,
    required super.manufacturer,
    required super.discount,
    required super.release,
    required super.stock,
    required super.sales,
    required super.status,
    super.category = CategoryEnum.gpu,
    required this.series,
    required this.capacity,
    required this.bus,
    required this.clockSpeed,
    super.enDescription,
    super.viDescription,
    super.imageUrl,
  });
}
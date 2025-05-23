import 'package:gizmoglobe_client/data/database/database.dart';
import 'package:gizmoglobe_client/objects/address_related/district.dart';
import 'package:gizmoglobe_client/objects/address_related/province.dart';
import 'package:gizmoglobe_client/objects/address_related/ward.dart';

class Address {
  String? addressID;
  String customerID;
  String receiverName;
  String receiverPhone;
  Province? province;
  District? district;
  Ward? ward;
  String? street;
  bool hidden;

  Address({
    this.addressID,
    required this.customerID,
    required this.receiverName,
    required this.receiverPhone,
    this.province,
    this.district,
    this.ward,
    this.street,
    this.hidden = false,
  });

  @override
  String toString({bool? isEnglish}) {
    return '$receiverName - $receiverPhone'
        '${street != null && street!.isNotEmpty ? ', $street' : ''}'
        '${ward != null && ward!.fullNameEn.isNotEmpty ? ', ${isEnglish == true ? ward!.fullNameEn : ward!.fullName}' : ''}'
        '${district != null && district!.fullNameEn.isNotEmpty ? ', ${isEnglish == true ? district!.fullNameEn : district!.fullName}' : ''}'
        '${province != null && province!.fullNameEn.isNotEmpty ? ', ${isEnglish == true ? province!.fullNameEn : province!.fullName}' : ''}';
  }

  String firstLine() {
    return '$receiverName - $receiverPhone';
  }

  String secondLine({bool? isEnglish}) {
    return '${street != null && street!.isNotEmpty ? '$street, ' : ''}'
        '${ward != null && ward!.fullNameEn.isNotEmpty ? '${isEnglish == true ? ward!.fullNameEn : ward!.fullName}, ' : ''}'
        '${district != null && district!.fullNameEn.isNotEmpty ? '${isEnglish == true ? district!.fullNameEn : district!.fullName}, ' : ''}'
        '${province != null && province!.fullNameEn.isNotEmpty ? (isEnglish == true ? province!.fullNameEn : province!.fullName) : ''}';
  }

  static Address nullAddress = Address(
    customerID: '',
    receiverName: '',
    receiverPhone: '',
  );

  Map<String, dynamic> toMap() {
    return {
      'addressID': addressID,
      'customerID': customerID,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'provinceCode': province?.code,
      'districtCode': district?.code,
      'wardCode': ward?.code,
      'street': street,
      'hidden': hidden,
    };
  }

  static Address fromMap(Map<String, dynamic> map) {
    final province = Database().provinceList.firstWhere(
        (p) => p.code == map['provinceCode'],
        orElse: () => Province.nullProvince);
    final district = province.districts?.firstWhere(
            (d) => d.code == map['districtCode'],
            orElse: () => District.nullDistrict) ??
        District.nullDistrict;
    final ward = district.wards?.firstWhere((w) => w.code == map['wardCode'],
            orElse: () => Ward.nullWard) ??
        Ward.nullWard;

    return Address(
      addressID: map['addressID'],
      customerID: map['customerID'],
      receiverName: map['receiverName'],
      receiverPhone: map['receiverPhone'],
      province: province,
      district: district,
      ward: ward,
      street: map['street'],
      hidden: map['hidden'],
    );
  }
}
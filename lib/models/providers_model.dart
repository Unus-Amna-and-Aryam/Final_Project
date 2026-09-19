class Providers {
  int? id;
  String? name;
  String? category;
  String? subCategory;
  String? phoneNumber;
  String? socialAccount;
  String? locationLink;
  num? minPrice;
  num? maxPrice;

  Providers({
    this.id,
    this.name,
    this.category,
    this.subCategory,
    this.phoneNumber,
    this.socialAccount,
    this.locationLink,
    this.minPrice,
    this.maxPrice,
  });

  Providers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    category = json['category'];
    subCategory = json['sub_category'];
    phoneNumber = json['phone_number'];
    socialAccount = json['social_account'];
    locationLink = json['location_link'];
    minPrice = json['min_price'];
    maxPrice = json['max_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['category'] = category;
    data['sub_category'] = subCategory;
    data['phone_number'] = phoneNumber;
    data['social_account'] = socialAccount;
    data['location_link'] = locationLink;
    data['min_price'] = minPrice;
    data['max_price'] = maxPrice;
    return data;
  }
}
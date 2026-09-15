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

  Providers(
      {this.id,
      this.name,
      this.category,
      this.subCategory,
      this.phoneNumber,
      this.socialAccount,
      this.locationLink,
      this.minPrice,
      this.maxPrice});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['category'] = this.category;
    data['sub_category'] = this.subCategory;
    data['phone_number'] = this.phoneNumber;
    data['social_account'] = this.socialAccount;
    data['location_link'] = this.locationLink;
    data['min_price'] = this.minPrice;
    data['max_price'] = this.maxPrice;
    return data;
  }
}
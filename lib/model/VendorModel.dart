class VendorModel {
  String author;

  String authorName;

  String authorProfilePic;

  String categoryID;

  String categoryPhoto;

  String categoryTitle;

  CreatedAt createdAt;

  String description;
  String fcmToken;

  Map<String, dynamic> filters;

  String id;

  double latitude;

  double longitude;

  String photo;

  List<dynamic> photos;

  String location;

  String price;

  num reviewsCount;

  num reviewsSum;

  String title;
  String phonenumber;

  VendorModel(
      {this.author = '',
      this.authorName = '',
      this.authorProfilePic = '',
      this.categoryID = '',
      this.categoryPhoto = '',
      this.categoryTitle = '',
      createdAt,
      this.description = '',
      this.filters = const {},
      this.id = '',
      this.fcmToken = '',
      this.latitude = 0.1,
      this.longitude = 0.1,
      this.photo = '',
      this.photos = const [],
      this.location = '',
      this.price = '',
      this.reviewsCount = 0,
      this.reviewsSum = 0,
      this.title = '',
      this.phonenumber = ''})
      : this.createdAt = createdAt ?? CreatedAt(nanoseconds: 0, seconds: 0);

  factory VendorModel.fromJson(Map<String, dynamic> parsedJson) {
    return VendorModel(
      author: parsedJson['author'] ?? '',
      authorName: parsedJson['authorName'] ?? '',
      authorProfilePic: parsedJson['authorProfilePic'] ?? '',
      categoryID: parsedJson['categoryID'] ?? '',
      categoryPhoto: parsedJson['categoryPhoto'] ?? '',
      categoryTitle: parsedJson['categoryTitle'] ?? '',
      createdAt: parsedJson.containsKey('createdAt') ? CreatedAt.fromJson(parsedJson['createdAt']) : CreatedAt(),
      description: parsedJson['description'] ?? '',
      filters: parsedJson['filters'] ?? {},
      fcmToken: (parsedJson['fcmToken'] == null) ? '' : parsedJson['fcmToken'],
      id: parsedJson['id'] ?? '',
      latitude: parsedJson['latitude'] ?? 0.1,
      longitude: parsedJson['longitude'] ?? 0.1,
      photo: parsedJson['photo'] ?? '',
      photos: parsedJson['photos'] ?? [],
      location: parsedJson['location'] ?? '',
      price: parsedJson['price'] ?? '',
      reviewsCount: parsedJson['reviewsCount'] ?? 0,
      reviewsSum: parsedJson['reviewsSum'] ?? 0,
      title: parsedJson['title'] ?? '',
      phonenumber: parsedJson['phonenumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': this.author,
      'authorName': this.authorName,
      'authorProfilePic': this.authorProfilePic,
      'categoryID': this.categoryID,
      'categoryPhoto': this.categoryPhoto,
      'categoryTitle': this.categoryTitle,
      'createdAt': this.createdAt.toJson(),
      'description': this.description,
      'fcmToken': this.fcmToken,
      'filters': this.filters,
      'id': this.id,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'photo': this.photo,
      'photos': this.photos,
      'location': this.location,
      'price': this.price,
      'reviewsCount': this.reviewsCount,
      'reviewsSum': this.reviewsSum,
      'title': this.title,
      'phonenumber': this.phonenumber,
    };
  }
}

class CreatedAt {
  num nanoseconds;

  num seconds;

  CreatedAt({this.nanoseconds = 0.0, this.seconds = 0.0});

  factory CreatedAt.fromJson(Map<dynamic, dynamic> parsedJson) {
    return CreatedAt(
      nanoseconds: parsedJson['_nanoseconds'] ?? '',
      seconds: parsedJson['_seconds'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_nanoseconds': this.nanoseconds,
      '_seconds': this.seconds,
    };
  }
}

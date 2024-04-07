import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String comment;
  final String name;
  final int rating;
  final int likeCounts;
  final List<dynamic> likedBy;
  final Timestamp timestamp;

  Review({
    required this.id,
    required this.comment,
    required this.name,
    required this.rating,
    required this.likeCounts,
    required this.likedBy,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      comment: data['comment'],
      name: data['name'],
      rating: data['rating'],
      timestamp: data['timestamp'],
      likeCounts: data['likeCounts'],
      likedBy:data['likedBy'],
    );
  }
}
class Report {
  final String id;
  final String user;
  final String desc;
  final String status;
  final Timestamp timestamp;

  Report({
    required this.id,
    required this.user,
    required this.desc,
    required this.status,
    required this.timestamp,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      user: data['user'],
      desc: data['desc'],
      status: data['status'],
      timestamp: data['timestamp'],
    );
  }
}

class Restroom {
  final String id;
  final String address;
  final String availabilityHours;
  final List<String> gender;
  final bool handicappedAccessible;
  final String handledBy;
  final GeoPoint location;
  final String name;
  final List<String> images;
  final double ratings;
  final List<Review> reviews;
  final List<Report> reports;
  final int no_of_reviews;
  final int no_of_reports;
  final List<dynamic> savedBy;

  Restroom({
    required this.id,
    required this.address,
    required this.availabilityHours,
    required this.gender,
    required this.handicappedAccessible,
    required this.handledBy,
    required this.location,
    required this.name,
    required this.images,
    required this.ratings,
    required this.reviews,
    required this.reports,
    required this.no_of_reviews,
    required this.no_of_reports,
    required this.savedBy,
  });

  factory Restroom.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<Review> reviews = [];
    List<Report> reports = [];
    // (data['ratings'] ?? 0.0).toDouble(),
    double ratingsInt= ( data['ratings'] is double) ?  data['ratings'] : 0.0;
    int no_of_reviewsInt= ( data['no_of_reviews'] is int) ?  data['no_of_reviews'] : 0;
    int no_of_reportsInt= ( data['no_of_reports'] is int) ?  data['no_of_reports'] : 0;

    if (data['reviews'] != null) {
      reviews = List.from(data['reviews']).map((reviewData) => Review.fromFirestore(reviewData)).toList();
    }
    if (data['reports'] != null) {
      reports = List.from(data['reports']).map((reportData) => Report.fromFirestore(reportData)).toList();
    }
    return Restroom(
        id: doc.id,
        address: data['address'],
        availabilityHours: data['availabilityHours'],
        gender: List<String>.from(data['gender']),
        handicappedAccessible: data['handicappedAccessible'],
        handledBy: data['handledBy'],
        location: data['location'],
        name: data['name'],
        images:List<String>.from(data['images']),
        ratings: ratingsInt,
        reviews: reviews,
        reports: reports,
        no_of_reviews:no_of_reviewsInt,
        no_of_reports:no_of_reportsInt,
        savedBy:data['savedBy']
    );
  }
  static Future<List<dynamic>> getSavedBy(String restroomId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('restrooms')
          .doc(restroomId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('savedBy')) {
          return data['savedBy'] ?? []; // Return savedBy data or an empty list if null
        }
      }
      return []; // Return an empty list if the document doesn't exist or savedBy field is not found
    } catch (error) {
      print("Error getting savedBy data: $error");
      throw error; // Throw the error for handling in the UI
    }
  }
}

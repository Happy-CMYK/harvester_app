class Review {
  final String id;
  final String orderId;
  final String reviewerId; // 评价者ID
  final String revieweeId; // 被评价者ID
  final int rating; // 评分 1-5
  final String comment; // 评价内容
  final DateTime createdAt;

  Review({
    required this.id,
    required this.orderId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      orderId: json['orderId'],
      reviewerId: json['reviewerId'],
      revieweeId: json['revieweeId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class UserRating {
  final String userId;
  final double averageRating;
  final int totalReviews;
  final List<Review> recentReviews;

  UserRating({
    required this.userId,
    required this.averageRating,
    required this.totalReviews,
    required this.recentReviews,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'recentReviews': recentReviews.map((r) => r.toJson()).toList(),
    };
  }

  factory UserRating.fromJson(Map<String, dynamic> json) {
    var reviewsList = json['recentReviews'] as List;
    List<Review> reviews = reviewsList.map((r) => Review.fromJson(r)).toList();

    return UserRating(
      userId: json['userId'],
      averageRating: json['averageRating'],
      totalReviews: json['totalReviews'],
      recentReviews: reviews,
    );
  }
}

class ReviewService {
  /// 提交评价
  static Future<bool> submitReview(Review review) async {
    // 模拟网络请求
    await Future.delayed(Duration(milliseconds: 500));
    
    // 模拟保存评价 (实际项目中会保存到数据库)
    print('📦 评价已提交: ${review.toJson()}');
    return true;
  }

  /// 获取用户评分
  static Future<UserRating> getUserRating(String userId) async {
    // 模拟网络请求
    await Future.delayed(Duration(milliseconds: 300));
    
    // 返回模拟数据
    return UserRating(
      userId: userId,
      averageRating: 4.5,
      totalReviews: 12,
      recentReviews: [
        Review(
          id: '1',
          orderId: '001',
          reviewerId: 'farmer_1',
          revieweeId: userId,
          rating: 5,
          comment: '服务很好，作业质量高',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
        ),
        Review(
          id: '2',
          orderId: '002',
          reviewerId: 'farmer_2',
          revieweeId: userId,
          rating: 4,
          comment: '按时完成作业，专业',
          createdAt: DateTime.now().subtract(Duration(days: 3)),
        ),
      ],
    );
  }
}
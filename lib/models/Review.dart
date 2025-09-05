class Review {
  static const String REVIEWER_UID_KEY = "_id";
  static const String REVIEWER_IMAGE_KEY = "profilePhoto";
  static const String RATING_KEY = "rating";
  static const String FEEDBACK_KEY = "review";

  String? reviewerUid;
  String? reviewerImage;
  int rating;
  String? feedback;
  String? date;
  Review({
    this.reviewerImage,
    this.reviewerUid,
    this.rating = 3,
    this.feedback,
    this.date,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      reviewerUid: map[REVIEWER_UID_KEY],
      reviewerImage: map[REVIEWER_IMAGE_KEY],
      rating: map[RATING_KEY],
      feedback: map[FEEDBACK_KEY],
      date: map['createdAt'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      REVIEWER_UID_KEY: reviewerUid,
      REVIEWER_IMAGE_KEY: reviewerImage,
      RATING_KEY: rating,
      FEEDBACK_KEY: feedback,
    };
    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (reviewerUid != null) map[REVIEWER_UID_KEY] = reviewerUid;
    map[RATING_KEY] = rating;
    if (feedback != null) map[FEEDBACK_KEY] = feedback;
    return map;
  }
}

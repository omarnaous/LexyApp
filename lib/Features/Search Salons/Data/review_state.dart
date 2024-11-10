abstract class ReviewState {
  const ReviewState();
}

class ReviewInitial extends ReviewState {}

class ReviewSubmitting extends ReviewState {}

class ReviewSubmitted extends ReviewState {}

class ReviewSubmissionError extends ReviewState {
  final String message;

  const ReviewSubmissionError(this.message);
}

enum ExerciseType { vocabulary, listenChoose, completePhrase, imageQuestion }

class DrivingExercise {
  final String id;
  final String lessonId;
  final int orderIndex;
  final ExerciseType type;
  final bool isExamQuestion;
  final Map<String, dynamic> content;

  const DrivingExercise({
    required this.id,
    required this.lessonId,
    required this.orderIndex,
    required this.type,
    required this.isExamQuestion,
    required this.content,
  });

  factory DrivingExercise.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = switch (typeStr) {
      'vocabulary' => ExerciseType.vocabulary,
      'listen_choose' => ExerciseType.listenChoose,
      'complete_phrase' => ExerciseType.completePhrase,
      'image_question' => ExerciseType.imageQuestion,
      _ => ExerciseType.vocabulary,
    };
    return DrivingExercise(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String,
      orderIndex: json['order_index'] as int,
      type: type,
      isExamQuestion: json['is_exam_question'] as bool? ?? false,
      content: json['content'] as Map<String, dynamic>,
    );
  }
}

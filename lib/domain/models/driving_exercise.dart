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

  // Vocabulary
  String get term => content['term'] as String;
  String get definition => content['definition'] as String;

  // ListenChoose + ImageQuestion
  List<String> get options => List<String>.from(content['options'] as List);
  int get correctIndex => content['correct_index'] as int;

  // ListenChoose
  String get text => content['text'] as String;

  // CompletePhrase
  String get prompt => content['prompt'] as String;
  String get answer => content['answer'] as String;
  List<String> get wordBank => List<String>.from(content['word_bank'] as List);

  // ImageQuestion + Vocabulary (optional)
  String? get imageUrl => content['image_url'] as String?;

  // ImageQuestion
  String get question => content['question'] as String;

  factory DrivingExercise.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = switch (typeStr) {
      'vocabulary' => ExerciseType.vocabulary,
      'listen_choose' => ExerciseType.listenChoose,
      'complete_phrase' => ExerciseType.completePhrase,
      'image_question' => ExerciseType.imageQuestion,
      _ => throw ArgumentError('Unknown exercise type: $typeStr'),
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


import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionsModel {
  String? id;
  String? semester;
  String? creditUnit;
  String? courseCode;
  String? courseTitle;
  int? timeSeconds;
  int? questionCount;
  List<Questions>? questions;
  List<Rating>? ratings;
  List<Review>? reviews;

  QuestionsModel({
        this.id,
        this.courseCode,
        this.courseTitle,
        this.timeSeconds,
        this.creditUnit,
        this.semester,
        this.questionCount,
        this.questions,
        this.ratings,
    this.reviews,
      });

  QuestionsModel.fromJson(Map<String, dynamic> json) :
    id = json['id'] as String,
    courseCode = json['course_code'] as String,
    courseTitle = json['course_title'] as String,
    semester = json['semester'] as String,
    creditUnit = json['credit_unit'] as String,
    timeSeconds = json['time_seconds'],
    questionCount = 0,
    questions = (json['questions'] as List)
        .map((dynamic e) => Questions.fromJson(e as Map<String, dynamic>))
        .toList(),
    ratings = (json['ratings'] as List)
      .map((dynamic e) => Rating.fromJson(e as Map<String, dynamic>))
      .toList(),
        reviews = (json['reviews'] as List)
            .map((dynamic e) => Review.fromJson(e as Map<String, dynamic>))
            .toList();

  QuestionsModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> json) :
        id = json.id,
        courseCode = json['course_code'] ,
        courseTitle = json['course_title'],
        semester = json['semester'] ,
        creditUnit = json['credit_unit'] ,
        timeSeconds = json['time_seconds'],
        questionCount = json['questions_count'];

  String timeInMinutes() => "${(timeSeconds! / 60).ceil()} minutes";


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['course_code'] = this.courseCode;
    data['course_title'] = this.courseTitle;
    data['time_seconds'] = this.timeSeconds;
    data['semester'] = this.semester;
    data['credit_unit'] = this.courseTitle;
    return data;
  }
}

class Questions {
  String id;
  String question;
  List<Answers> answers;
  String? correctAnswer;
  String? selectedAnswer;

  Questions({required this.id, required this.question, required this.answers, this.correctAnswer});

  Questions.fromJson(Map<String, dynamic> json) :
    id = json['id'],
    question = json['question'],
    answers = (json['answers'] as List).map((e) => Answers.fromJson(e)).toList(),
    correctAnswer = json['correct_answer'];

  Questions.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
  : id = snapshot.id,
    question = snapshot["question"],
    answers = [],
    correctAnswer = snapshot["correct_answer"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question'] = this.question;
    if (this.answers != null) {
      data['answers'] = this.answers.map((v) => v.toJson()).toList();
    }
    data['correct_answer'] = this.correctAnswer;
    return data;
  }
}

class Rating {
  String comment;
  int rating;
  bool isRated;

  Rating({required this.comment, required this.rating, required this.isRated});

  Rating.fromJson(Map<String, dynamic> json) :
      comment = json['comment'],
        rating = json['rating'],
        isRated = json['isRated'];

  Rating.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      :
      comment = snapshot['comment'],
        rating = snapshot["rating"],
        isRated = snapshot["isRated"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating'] = this.rating;
    data['comment'] = this.comment;
    data['isRated'] = this.isRated;
    return data;
  }
}

class Review {
  int allFives;
  int allFours;
  int allThrees;
  int allTwos;
  int allOnes;
  double rating;
  int ratingSum;
  int ratingCount;

  Review({required this.allFives, required this.allFours, required this.allThrees, required this.allTwos, required this.allOnes, required this.rating, required this.ratingCount, required this.ratingSum});

  Review.fromJson(Map<String, dynamic> json) :
        allFives = json['allFives'],
        allFours = json['allFours'],
        allThrees = json['allThrees'],
        allTwos = json['allTwos'],
        allOnes = json['allOnes'],
        rating = json['rating'],
        ratingSum = json['ratingSum'],
        ratingCount = json['ratingCount'];

  Review.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      :
        allFives = snapshot['allFives'],
        allFours = snapshot['allFours'],
        allThrees = snapshot['allThrees'],
        allTwos = snapshot['allTwos'],
        allOnes = snapshot['allOnes'],
        rating = snapshot['rating'],
        ratingSum = snapshot['ratingSum'],
        ratingCount = snapshot['ratingCount'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['allFives'] = this.allFives;
    data['allFours'] = this.allFours;
    data['allThrees'] = this.allThrees;
    data['allTwos'] = this.allTwos;
    data['allOnes'] = this.allOnes;
    data['rating'] = this.rating;
    data['ratingSum'] = this.ratingSum;
    data['ratingCount'] = this.ratingCount;
    return data;
  }
}

class Answers {
  String? identifier;
  String? answer;

  Answers({this.identifier, this.answer});

  Answers.fromJson(Map<String, dynamic> json) :
    identifier = json['identifier'],
    answer = json['Answer'];

  Answers.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
        identifier = snapshot['identifier'],
        answer = snapshot['answer'];


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['identifier'] = this.identifier;
    data['Answer'] = this.answer;
    return data;
  }
}

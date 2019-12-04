class Face {
  // 20 分为一档 分别是 1-20 21-40 ···
  static List status = ['很不开心', '不开心', '一般', '开心', '许极开心'];

  static String getStatusByNum(int number) {
    number = checkFaceNum(number);
    int index;
    if (number % 20 > 0) {
      index = number ~/ 20;
    } else {
      index = (number ~/ 20) - 1;
    }
    return status[index];
  }

  static int getIndexByNum(int number) {
    number = checkFaceNum(number);
    int index;
    if (number % 20 > 0) {
      index = number ~/ 20;
    } else {
      index = (number ~/ 20) - 1;
    }
    return index;
  }

  // 心情数值为 0 - 100
  static int checkFaceNum(int number) {
    if (number > 100) {
      return 100;
    } else if (number < 0) {
      return 0;
    } else {
      return number;
    }
  }
}

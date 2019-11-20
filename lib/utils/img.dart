class Img {
  static isLocal(String url) {
    return !url.contains('http://') && !url.contains('https://');
  }
}

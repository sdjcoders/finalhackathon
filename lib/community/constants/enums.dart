enum ThemeMode {
  light,
  dark,
}

enum Scores {
  comment(1),
  textPost(2),
  linkPost(3),
  imagePost(3),
  awardPost(5),
  deletePost(-1);

  final int score;
  const Scores(this.score);
}

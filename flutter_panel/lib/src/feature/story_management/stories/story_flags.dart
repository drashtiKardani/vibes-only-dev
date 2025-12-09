class StoryFlags {
  static final hotAndNew = {'display': 'Hot & New', 'value': 'new'};
  // static final featured = {'display': 'Featured', 'value': 'featured'};
  static final trending = {'display': 'Trending', 'value': 'trending'};
  static final top10 = {'display': 'Top 10', 'value': 'top_10'};
  static final staffPick = {'display': 'Our Faves', 'value': 'staff_pick'};

  static final List<Map<String, dynamic>> all = [
    hotAndNew,
    // featured,
    trending,
    top10,
    staffPick,
  ];
}

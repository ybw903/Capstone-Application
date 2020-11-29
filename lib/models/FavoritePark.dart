class FavoritePark{
  String id, name, address, p_class, op_day, tel, default_bill, add_bill, week_day_start,
      week_day_end,week_end_start, week_end_end;
  int avail;
  double lat, lng;

  FavoritePark({
    this.id,
    this.name,
    this.p_class,
    this.address,
    this.op_day,
    this.tel,
    this.default_bill,
    this.add_bill,
    this.week_day_start,
    this.week_day_end,
    this.week_end_start,
    this.week_end_end,
    this.avail,
    this.lat,
    this.lng
  });

  factory FavoritePark.fromJson(Map<String, dynamic> json){

    return FavoritePark(
      id: json["id"],
      name: json["name"],
      p_class: json["p_class"],
      address: json["address"],
      op_day: json["op_day"],
      tel: json["tel"],
      default_bill: json["default_bill"],
      add_bill: json["add_bill"],
      week_day_start: json["week_day_start"],
      week_day_end: json["week_day_end"],
      week_end_start: json["week_end_start"],
      week_end_end: json["week_end_end"],
      avail: json["avail"],
      lat: json["lat"],
      lng: json["lng"],
    );
  }
}
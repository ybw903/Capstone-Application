class Park{
  final String id, name, p_class, p_type, address,  day_type, op_day, bill_tpye, tel, default_bill, add_bill, last_update, week_day_start,
      week_day_end,week_end_start, week_end_end;
  final int avail;
  final double lat, lng;

  Park({
    this.id,
    this.name,
    this.p_class,
    this.p_type,
    this.address,
    this.day_type,
    this.op_day,
    this.bill_tpye,
    this.tel,
    this.default_bill,
    this.add_bill,
    this.last_update,
    this.week_day_start,
    this.week_day_end,
    this.week_end_start,
    this.week_end_end,
    this.avail,
    this.lat,
    this.lng
  });
  factory Park.fromJson(Map<String, dynamic> json){
    return Park(
      id: json["id"],
      name: json["name"],
      p_class: json["p_class"],
      p_type: json["p_type"],
      address: json["address"],
      day_type: json["day_type"],
      op_day: json["op_day"],
      bill_tpye: json["bill_type"],
      tel: json["tel"],
      default_bill: json["default_bill"],
      add_bill: json["add_bill"],
      last_update: json["last_update"],
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

Park park = Park(
  id:"152-1-000001",
  name: "주차장",
  p_class: "공영",
  p_type: "노상",
  address: "대구광역시 서구 비산동 3418-1",
  day_type: "미시행",
  op_day: "평일",
  bill_tpye: "무료",
  tel: "0525-2481",
  default_bill: "30분간 400원",
  add_bill: "10분당 300원",
  last_update: "2018-03-31",
  week_day_start: "08:00",
  week_day_end: "20:00",
  week_end_start: "00:00",
  week_end_end: "00:00",
  avail: 504,
  lat: 37.4,
  lng: 38,
);
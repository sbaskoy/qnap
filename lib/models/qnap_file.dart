class QnapFile {
  String? id;
  String? cls;
  String? text;
  int? noSetup;
  int? isCached;
  int? draggable;
  String? iconCls;
  int? noSupportACL;
  int? maxItemLimit;
  int? realTotal;

  QnapFile(
      {this.id,
      this.cls,
      this.text,
      this.noSetup,
      this.isCached,
      this.draggable,
      this.iconCls,
      this.noSupportACL,
      this.maxItemLimit,
      this.realTotal});

  QnapFile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cls = json['cls'];
    text = json['text'];
    noSetup = json['no_setup'];
    isCached = json['is_cached'];
    draggable = json['draggable'];
    iconCls = json['iconCls'];
    noSupportACL = json['noSupportACL'];
    maxItemLimit = json['max_item_limit'];
    realTotal = json['real_total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cls'] = this.cls;
    data['text'] = this.text;
    data['no_setup'] = this.noSetup;
    data['is_cached'] = this.isCached;
    data['draggable'] = this.draggable;
    data['iconCls'] = this.iconCls;
    data['noSupportACL'] = this.noSupportACL;
    data['max_item_limit'] = this.maxItemLimit;
    data['real_total'] = this.realTotal;
    return data;
  }
}

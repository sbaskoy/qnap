class FileListResponse {
  int? medialib;
  int? total;
  int? acl;
  int? isAclEnable;
  int? isWinaclSupport;
  int? isWinaclEnable;
  int? rttSupport;
  int? page;
  List<Datas>? datas;

  FileListResponse(
      {this.medialib,
      this.total,
      this.acl,
      this.isAclEnable,
      this.isWinaclSupport,
      this.isWinaclEnable,
      this.rttSupport,
      this.page,
      this.datas});

  FileListResponse.fromJson(Map<String, dynamic> json) {
    medialib = json['medialib'];
    total = json['total'];
    acl = json['acl'];
    isAclEnable = json['is_acl_enable'];
    isWinaclSupport = json['is_winacl_support'];
    isWinaclEnable = json['is_winacl_enable'];
    rttSupport = json['rtt_support'];
    page = json['page'];
    if (json['datas'] != null) {
      datas = <Datas>[];
      json['datas'].forEach((v) {
        datas!.add(new Datas.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['medialib'] = this.medialib;
    data['total'] = this.total;
    data['acl'] = this.acl;
    data['is_acl_enable'] = this.isAclEnable;
    data['is_winacl_support'] = this.isWinaclSupport;
    data['is_winacl_enable'] = this.isWinaclEnable;
    data['rtt_support'] = this.rttSupport;
    data['page'] = this.page;
    if (this.datas != null) {
      data['datas'] = this.datas!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Datas {
  String? filename;
  int? isfolder;
  String? filesize;
  String? group;
  String? owner;
  int? iscommpressed;
  String? privilege;
  int? filetype;
  String? mt;
  int? epochmt;
  String? randno;
  int? exist;
  int? mp4240;
  int? mp4360;
  int? mp4720;
  int? mp4480;
  int? mp41080;
  int? mp4Org;
  int? mp3;
  int? trans;
  int? stickyBit;
  int? projectionType;
  int? isCached;

  Datas(
      {this.filename,
      this.isfolder,
      this.filesize,
      this.group,
      this.owner,
      this.iscommpressed,
      this.privilege,
      this.filetype,
      this.mt,
      this.epochmt,
      this.randno,
      this.exist,
      this.mp4240,
      this.mp4360,
      this.mp4720,
      this.mp4480,
      this.mp41080,
      this.mp4Org,
      this.mp3,
      this.trans,
      this.stickyBit,
      this.projectionType,
      this.isCached});

  Datas.fromJson(Map<String, dynamic> json) {
    filename = json['filename'];
    isfolder = json['isfolder'];
    filesize = json['filesize'];
    group = json['group'];
    owner = json['owner'];
    iscommpressed = json['iscommpressed'];
    privilege = json['privilege'];
    filetype = json['filetype'];
    mt = json['mt'];
    epochmt = json['epochmt'];
    randno = json['randno'];
    exist = json['exist'];
    mp4240 = json['mp4_240'];
    mp4360 = json['mp4_360'];
    mp4720 = json['mp4_720'];
    mp4480 = json['mp4_480'];
    mp41080 = json['mp4_1080'];
    mp4Org = json['mp4_org'];
    mp3 = json['mp3'];
    trans = json['trans'];
    stickyBit = json['sticky_bit'];
    projectionType = json['projection_type'];
    isCached = json['is_cached'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filename'] = this.filename;
    data['isfolder'] = this.isfolder;
    data['filesize'] = this.filesize;
    data['group'] = this.group;
    data['owner'] = this.owner;
    data['iscommpressed'] = this.iscommpressed;
    data['privilege'] = this.privilege;
    data['filetype'] = this.filetype;
    data['mt'] = this.mt;
    data['epochmt'] = this.epochmt;
    data['randno'] = this.randno;
    data['exist'] = this.exist;
    data['mp4_240'] = this.mp4240;
    data['mp4_360'] = this.mp4360;
    data['mp4_720'] = this.mp4720;
    data['mp4_480'] = this.mp4480;
    data['mp4_1080'] = this.mp41080;
    data['mp4_org'] = this.mp4Org;
    data['mp3'] = this.mp3;
    data['trans'] = this.trans;
    data['sticky_bit'] = this.stickyBit;
    data['projection_type'] = this.projectionType;
    data['is_cached'] = this.isCached;
    return data;
  }
}

String ezEncode(String str) {
  String ezEncodeChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  String out = '';
  int length = str.length;

  int i = 0;
  while (i < length) {
    int c1 = str.codeUnitAt(i) & 0xff;
    i++;
    if (i == length) {
      out += ezEncodeChars[c1 >> 2];
      out += ezEncodeChars[(c1 & 0x3) << 4];
      out += '==';
      break;
    }
    int c2 = str.codeUnitAt(i);
    i++;
    if (i == length) {
      out += ezEncodeChars[c1 >> 2];
      out += ezEncodeChars[((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4)];
      out += ezEncodeChars[(c2 & 0xF) << 2];
      out += '=';
      break;
    }
    int c3 = str.codeUnitAt(i);
    i++;
    out += ezEncodeChars[c1 >> 2];
    out += ezEncodeChars[((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4)];
    out += ezEncodeChars[((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6)];
    out += ezEncodeChars[c3 & 0x3F];
  }

  return out;
}

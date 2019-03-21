new String:hexchars[] = "0123456789ABCDEF";

url_encode(String:strFrom[], lenFrom, String:strTo[], lenTo)
{
    new c;
    new to = 0, from = 0;
    decl String:strTmp[lenFrom*3+1];

    while ( from < lenFrom ) {
        c = strFrom[from++];
        if ( c == '\0' ) {
            break;
        } else if ( c == ' ' ) {
            strTmp[to++] = '+';
        } else if ( IsCharAlpha(c) || IsCharNumeric(c) || ('_' == c) || ('-' == c) || ('.' == c) ) {
            strTmp[to++] = c;
        } else {
            strTmp[to++] = '%';
            strTmp[to++] = hexchars[c >> 4];
            strTmp[to++] = hexchars[c & 15];
        }
    }
    strTmp[to] = '\0';
    strcopy(strTo, lenTo, strTmp);
}


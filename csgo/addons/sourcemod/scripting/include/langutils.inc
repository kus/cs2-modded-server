FormatLanguageNumberTextEx(client, String:text[], size, number, const String:tplName[])
{
    SetGlobalTransTarget(client);
    decl String:tpl[64];
    new num10 = number % 10;
    new num100 = number % 100;

    if ( number == 1 ) {
        Format(tpl, sizeof(tpl), "1>%s", tplName);
    } else if ( (num10 == 1) && (num100 != 11) ) {
        Format(tpl, sizeof(tpl), "x1>%s", tplName);
    } else if ( (num10 >= 2) && (num10 <= 4) && ((num100 < 12) || (num100 > 14)) ) {
        Format(tpl, sizeof(tpl), "x2-x4>%s", tplName);
    } else {
        Format(tpl, sizeof(tpl), "x5-x20>%s", tplName);
    }
    Format(text, size, "%t", tpl, number);
}


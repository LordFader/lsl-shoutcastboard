string parcelURL;
integer publicChannel = -6928184;
integer dataRequestChannel = -4681466;
string lasterSong = "";
string lastSong = "";
string thisSong = "";
string details = "";

update(){
    llMessageLinked(LINK_THIS, 204000, details, "1");
    llMessageLinked(LINK_THIS, 204000, thisSong, "2");
    llMessageLinked(LINK_THIS, 204000, lastSong, "3");
    llMessageLinked(LINK_THIS, 204000, lasterSong, "4");
    visualizer(details);
}

string clean(string str){
    str = strPatRep(str, "+", " ");
    return str;
}

string strPatRep (string str, string pat, string rep) {
    return llDumpList2String(llParseStringKeepNulls(str, [pat], []), rep);
}

list getLinkWithName(string name){
    list linkNumbers;
    integer i = llGetLinkNumber() != 0;
    integer x = llGetNumberOfPrims() + i;
    for (; i < x; ++i){
        if (llToLower(llGetLinkName(i)) == llToLower(name)){
            linkNumbers+=[i];
        }
    }
    return linkNumbers;
}

visualizer(string on){
    list vizs = getLinkWithName("visualizer");
    integer x = llGetListLength(vizs);
    float alpha;
    if (llStringLength(on) > 1){
        alpha = 0.9;
    }
    else{
        alpha = 0.0;
    }
    while (x--){
        llSetLinkAlpha(llList2Integer(vizs, x), alpha, ALL_SIDES);
    }
}

default{
    state_entry(){
        llListen(publicChannel, "", "", "");
        llListen(dataRequestChannel, "", "", "");
        llSetTimerEvent(0.1);
    }
    
    listen(integer c, string n, key i, string m){
        if (c == publicChannel){
            list d = llGetObjectDetails(i, [OBJECT_GROUP]);
            key group = llList2Key(d, 0);
            d = llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_GROUP]);
            key parcel = llList2Key(d, 0);
            if(group != parcel) return;
            parcelURL = m;
        }
        else if (c == dataRequestChannel){
            if (m == "thisSong"){
                llRegionSayTo(i, dataRequestChannel, thisSong);
            }
            else if (m == "lastSong"){
                llRegionSayTo(i, dataRequestChannel, lastSong);
            }
            else if (m == "details"){
                llRegionSayTo(i, dataRequestChannel, details);
            }
        }
    }

    timer(){
        llSetTimerEvent(5);
        string url = llGetParcelMusicURL();
        if (llStringLength(url) > 2){
            parcelURL = url;
        }
        if (llStringLength(parcelURL) < 2) return;
        parcelURL += "/7.html";
        llHTTPRequest(parcelURL, [HTTP_USER_AGENT, "LLSucksBalls (Mozilla Compatible)"], "");
    }
    
    http_response(key id, integer status, list meta, string body){
        string feed = llGetSubString(body,llSubStringIndex(body, "<body>") + llStringLength("<body>"), llSubStringIndex(body,"</body>") - 1);
        list feed_list = llParseString2List(feed, [","], []);
        string listeners = llList2String(feed_list, 0);
        string maxListen = llList2String(feed_list, 3);
        string bitrate = llList2String(feed_list, 5);
        string current_title_info = llList2String(feed_list,6);
        integer length = llGetListLength(feed_list);
        if(llList2String(feed_list, 7)){
            integer a = 7;
            for(; a < length; ++a){
                current_title_info += ", " + llList2String(feed_list, a);
            }
        }
        details = "";
        if (current_title_info){
            current_title_info = clean(current_title_info);
            if (thisSong != current_title_info){
                lasterSong = lastSong;
                lastSong = thisSong;
            }
            thisSong = current_title_info;
            details = "[" + listeners + "/" + maxListen + "] " + bitrate;
            details = clean(details);
        }
        update();
    }
}

string parcelURL;
integer publicChannel = -6928184;
integer dataRequestChannel = -4681466;
integer privateChannel;
integer titleChannel;
integer musicChannel;
integer listener;

list DJs;
list streamNames;
list streamURLs;
string notecardName;
integer notecardLine;

string title;
string streamName;

dialog(key id){
    llListenRemove(listener);
    privateChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    listener = llListen(privateChannel, "", id, "");
    llSetTimerEvent(30);
    list options = ["Set Title", "Music URL"];
    options += streamNames;
    llDialog(id, "Select", options, privateChannel);
}

getTitle(key id){
    llListenRemove(listener);
    titleChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    listener = llListen(titleChannel, "", id, "");
    llSetTimerEvent(30);
    llTextBox(id, "Enter Board Title or Cancel.", titleChannel);
}

setTitle(string m){
    title = m;
    llMessageLinked(LINK_THIS, 204000, m, "0");
}

getMusic(key id){
    llListenRemove(listener);
    musicChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    listener = llListen(musicChannel, "", id, "");
    llSetTimerEvent(30);
    llTextBox(id, "Enter Music URL or Cancel.", musicChannel);
}

setMusic(string url){
    url = llStringTrim(url, STRING_TRIM);
    if (llStringLength(url) > 2){
        parcelURL = url;
    }
    llRegionSay(publicChannel, parcelURL);
    llSetParcelMusicURL(parcelURL);
}

getNotecardData(){
    notecardLine = 0;
    notecardName = llGetInventoryName(INVENTORY_NOTECARD, 0);
    if (llStringLength(notecardName) > 1){
        llGetNotecardLine(notecardName, notecardLine);
    }
    llSetText("Reading Notecard...", <1,1,1>, 1);
}

notecardData(string line){
    list p = llParseString2List(line, ["=", "://"], []);
    if (llList2String(p, 2)){
        streamNames += [llList2String(p, 0)];
        streamURLs += [llList2String(p, 1) + "://" + llList2String(p, 2)];
    }
    else if (llStringLength(line) == 36){
        DJs += [(key)line];
    }
    ++notecardLine;
    llGetNotecardLine(notecardName, notecardLine);
}

integer sameGroup(key id){
    if (llListFindList(DJs, [id]) >= 0){
        return TRUE;
    }
    if (!llSameGroup(id)){
        llRegionSayTo(id, 0, "Your active group must match the active group of the board.");
        return FALSE;
    }
    return TRUE;
}

default{
    on_rez(integer n){
        llResetScript();
    }
    
    state_entry(){
        title = llList2String(llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_NAME]),0);
        setTitle(title);
        getNotecardData();
        llListen(dataRequestChannel, "", "", "");
    }
    
    dataserver(key query_id, string data){
        if (data == EOF){
            llSetText("", <1,1,1>, 1);
        }
        else{
            notecardData(data);
        }
    }
    
    changed(integer change){
        if (change & CHANGED_INVENTORY){
            llResetScript();
        }
    }

    touch_start(integer n){
        key id = llDetectedKey(0);
        if (!sameGroup(id)) return;
        dialog(id);
    }
    
    listen(integer c, string n, key i, string m){
        llListenRemove(listener);
        if (c == dataRequestChannel){
            if (m == "title"){
                llRegionSayTo(i, dataRequestChannel, title);
            }
            else if (m == "streamName"){
                llRegionSayTo(i, dataRequestChannel, streamName);
            }
        }
        else{
            if (!sameGroup(i)) return;
            if (c == privateChannel){
                if (m == "Set Title"){
                    getTitle(i);
                }
                else if (m == "Music URL"){
                    getMusic(i);
                }
                else if (llListFindList(streamNames, [m]) >= 0){
                    streamName = m;
                    integer x = llListFindList(streamNames, [m]);
                    setMusic(llList2String(streamURLs, x));
                }
            }
            if (c == titleChannel){
                setTitle(m);
            }
            if (c == musicChannel){
                setMusic(m);
            }
        }
    }
    
    timer(){
        llListenRemove(listener);
    }
}

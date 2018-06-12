string parcelURL;
integer publicChannel = -6928184;

string url;

default{
    on_rez(integer n){
        llResetScript();
    }
    
    state_entry(){
        llSetTimerEvent(0.1);
        llListen(publicChannel, "", "", "");
    }
    
    listen(integer c, string n, key i, string m){
        parcelURL = m;
        llSetParcelMusicURL(m);
    }
    
    timer(){
        llSetTimerEvent(5);
        url = llGetParcelMusicURL();
        if (llStringLength(url) > 2){
            parcelURL = url;
            llRegionSay(publicChannel, parcelURL);
        }
    }
}

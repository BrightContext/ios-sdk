//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

/* resources */
#ifndef BC_CONSTANTS_H

#define BC_ACTION_GET @"GET"
#define BC_ACTION_POST @"POST"

#define BC_API_LOADBALANCER @"http://pub.brightcontext.com"
#define BC_API_PROTOCOL @"ws://"
#define BC_API_ROOT @"/api"
#define BC_API_SOCKET_PATH @"/feed/ws"
#define BC_API_SERVER_TIME @"/api/server/time.json"
#define BC_API_SESSION_CREATE @"/api/session/create.json"
#define BC_API_FEED_SESSION_CREATE @"/api/feed/session/create.json"
#define BC_API_FEED_SESSION_DELETE @"/api/feed/session/delete.json"
#define BC_API_FEED_MESSAGE_CREATE @"/api/feed/message/create.json"
#define BC_API_FEED_MESSAGE_HISTORY @"/api/feed/message/history.json"
#define BC_API_TIMELINE_TIMEPOINTS @"/api/timeline/timepoints.json"
#define BC_API_CHANNEL_DESCRIPTION @"/api/channel/description.json"

#define BC_HEARTBEAT_COMMAND @"heartbeat"
#define BC_HEARTBEAT_INTERVAL 45

/* event types */
#define BC_EVENT_TYPE_MESSAGE @"onfeedmessage"
#define BC_EVENT_TYPE_RESPONSE @"onresponse"
#define BC_EVENT_TYPE_ERROR @"onerror"

/* feed types */

#define BC_FEED_TYPE_IN @"IN"
#define BC_FEED_TYPE_OUT @"OUT"
#define BC_FEED_TYPE_THRU @"THRU"
#define BC_FEED_DEFAULT_SUBCHANNEL @"DefaultThruProc"

/* command and query string parameters */

#define BC_PARAM_COMMAND @"cmd"
#define BC_PARAM_COMMAND_PARAMS @"params"

#define BC_PARAM_FILTERS @"filters"
#define BC_PARAM_SUBCHANNEL @"subChannel"
#define BC_PARAM_API_KEY @"apiKey"
#define BC_PARAM_EVENT_TYPE @"eventType"
#define BC_PARAM_EVENT_KEY @"eventKey"
#define BC_PARAM_SESSION_ID @"sid"
#define BC_PARAM_FEED @"feed"
#define BC_PARAM_FEED_KEY @"feedKey"
#define BC_PARAM_FEED_KEY_LIST @"fklist"
#define BC_PARAM_MESSAGE_NUM @"msgNum"
#define BC_PARAM_PAGE_SIZE @"pageSize"
#define BC_PARAM_START_AT @"startAt"
#define BC_PARAM_CURRENT_RELATIVE_TIME @"currTime"
#define BC_PARAM_PREV_X @"prevX"
#define BC_PARAM_NEXT_X @"nextX"
#define BC_PARAM_TIMELINE_ID @"tlid"
#define BC_PARAM_MESSAGE @"message"
#define BC_PARAM_METADATA @"metadata"
#define BC_PARAM_STATE @"state"
#define BC_PARAM_MSG @"msg"
#define BC_PARAM_PROC_ID @"procId"
#define BC_PARAM_NAME @"name"
#define BC_PARAM_NETWORK_ID @"netId"
#define BC_PARAM_SINCE_TS @"sinceTS"
#define BC_PARAM_LIMIT @"limit"
#define BC_PARAM_PROJECT @"project"
#define BC_PARAM_TSLOT_U @"utslot"
#define BC_PARAM_TSLOT_C @"tslot"
#define BC_PARAM_WRITE_KEY @"writeKey"

/* logging */
#ifdef BC_LOGGING
#   define BCLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define BCLog(...)
#endif

/* session and streaming */
#define BC_COOKIE_NAME @"BC_Session"
#define BC_COOKIE_KEY_SESSIONID @"sessid"
#define BC_COOKIE_KEY_GENDER @"g"
#define BC_COOKIE_KEY_AGEGROUP @"ag"
#define BC_COOKIE_KEY_LOCATION @"l"
#define BC_COOKIE_KEY_POLITICALPARTY @"p"
#define BC_RSTATE_INITIAL @"INITIAL"
#define BC_RSTATE_UPDATE @"UPDATE"
#define BC_RSTATE_REVOTE @"REVOTE"
#define BC_STREAMMODE_STREAM @"STREAM"
#define BC_STREAMMODE_LONGPOLL @"LONG_POLL"

/* client-side constants */
#define kBCSessionRequestErrorThreshold 5
#define kBCTZDELIMETER @":"
#define kBCFEEDKEYDELIMITER @"."
#define kBCFetchResultsKey @"content"

/* timepoints, messages and assets */
#define BC_SERVER_DATESTAMP_FORMAT @"EEE MMM dd HH:mm:ss zzz yyyy"
#define BC_INCREMENT_DAY @"DAY"
#define BC_INCREMENT_HOUR @"HOUR"
#define BC_INCREMENT_MIN @"MIN"
#define BC_SORTORDER_ASC @"ASC"
#define BC_SORTORDER_DESC @"DESC"

typedef enum
{
    BCHistoryTimeslotSize_Day,
    BCHistoryTimeslotSize_Hour,
    BCHistoryTimeslotSize_Minute,
    BCHistoryTimeslotSize_Default
} BCHistoryTimeslotSize;

typedef enum {
    BCSortOrder_Desc,
    BCSortOrder_Asc,
    BCSortOrder_Default = BCSortOrder_Desc
} BCSortOrder;

typedef enum {
    BCActivityState_NONE,
    BCActivityState_INITIAL,
    BCActivityState_UPDATE,
    BCActivityState_REVOTE
} BCActivityState;

/* basic function macros */

#define BC_CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))
#define URLEncode(__S__) [[[[__S__ stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@":" withString:@"%3A"] stringByReplacingOccurrencesOfString:@"," withString:@"%2C"] stringByReplacingOccurrencesOfString:@"@" withString:@"%40"]
#define spinwait(_SECONDS_) [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:_SECONDS_]]



#if BC_MESSAGE_CONTRACT_VALIDATION

/* validation */

#define BC_FIELDTYPE_STRING @"S"
#define BC_FIELDTYPE_DATE @"D"
#define BC_FIELDTYPE_NUMBER @"N"

typedef enum {
    BCFieldValidation_None = 0,
    BCFieldValidation_MinMax = 1
} BCFieldValidationType;

#endif



#define BC_CONSTANTS_H
#endif


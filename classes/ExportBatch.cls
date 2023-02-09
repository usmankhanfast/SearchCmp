global class ExportBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id from account Limit 1]);
    }
    
    global void execute(Database.BatchableContext BC, List<account> accList){
        system.debug('--');
        Map<String, String> repMap = new Map<String, String>{'Awaiting Award' => '00O1T000006MqkAUAS', 'Active Proposals_RFIs' => '00O1T0000064PkuUAE', 'WEEKLY 6 Month Pipeline' => '00O1T000006N3laUAC', 'WEEKLY 6-12 Month Horizon' => '00O1T0000076Hc6UAE'};
            
            for(String repName: repMap.keySet()) {
                ApexPages.PageReference report = new ApexPages.PageReference('/'+repMap.get(repName)+'?csv=1&isdtp=p1'); 
                ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; 
                cVersion.Origin = 'H';
                cVersion.PathOnClient = 'document3.csv';
                cVersion.OwnerId = UserInfo.getUserId();//Update owner
                cVersion.Title = 'documentdel';
                if(Test.isRunningTest()) { 
                    cVersion.VersionData = blob.valueOf('Unit.Test');
                } else {
                    cVersion.VersionData = report.getContent();
                }
                calloutD(cVersion.VersionData, repName);               
            }
    }
    
    public static void calloutD(blob versionData, String fileName){
        String accessToken = getToken();    
        HttpRequest httpRequestToSend = new HttpRequest(); 
        fileName = fileName+' '+system.now()+'.csv';
        fileName = fileName.replace(' ', '_');
        fileName = fileName.replace(':', '_');
        drtstrategy.sharepoint.com/sites/DRTAutomatedSalesandFinancialReporting/
        httpRequestToSend.setEndpoint('https://drtstrategy.sharepoint.com/sites/DRTAutomatedSalesandFinancialReporting/_api/web/GetFolderByServerRelativeUrl(\'/sites/DRTAutomatedSalesandFinancialReporting/Shared%20Documents/Reports\')/Files/add(url=\''+fileName+'\',overwrite=true)');    
        httpRequestToSend.setMethod('POST');
        httpRequestToSend.setHeader('Authorization', 'Bearer ' + accessToken);
        
        httpRequestToSend.setHeader('Content-Type', 'application/json;odata=verbose');
        httpRequestToSend.setBodyAsBlob(versionData);
        Http http = new Http();   
        HttpResponse httpResponse = http.send(httpRequestToSend);
        
        if(httpResponse.getStatusCode()==401) {
            system.debug('-401-');
        }
        System.debug('***** httpResponse-->' + httpResponse);
    }
    
    public static String getToken() {
        HttpRequest httpRequestToSend = new HttpRequest();
        
        httpRequestToSend.setEndpoint('https://accounts.accesscontrol.windows.net/e330cfd2-d4d5-4fc9-81c6-a42d71ad09ce/tokens/OAuth/2');    
        httpRequestToSend.setMethod('POST');
        httpRequestToSend.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String clientId = '06436e7a-a73e-4ac9-b388-dd5fa7f922f2@87907297-addb-49a8-bfa1-5282ebe7708e';
        string clientSecret = 'B4etZWRmsqK2dpxQwJl1m6JMQ+Cezv5kDmnvC0+dalU=';
        string resourceToken = '00000003-0000-0ff1-ce00-000000000000/drtstrategy.sharepoint.com@87907297-addb-49a8-bfa1-5282ebe7708e';
        String payload = 'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+'&resource='+EncodingUtil.urlEncode(resourceToken,'UTF-8')+'&grant_type=client_credentials';
        
        httpRequestToSend.setBody(payload);   
        Http http = new Http();   
        HttpResponse httpResponse = http.send(httpRequestToSend);
        System.debug('***** httpResponse-->' + httpResponse.getBody());
        
        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
        return (String)responseMap.get('access_token');
    }
    
    global void finish(Database.BatchableContext BC){
    }
}
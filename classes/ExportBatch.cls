global class ExportBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id from account Limit 1]);
    }
    
    global void execute(Database.BatchableContext BC, List<account> accList){
        system.debug('--');
        Map<String, String> repMap = new Map<String, String>{'Awaiting Award' => '00O1y000000rATkEAM'};            
            for(String repName: repMap.keySet()) {
                ApexPages.PageReference report = new ApexPages.PageReference('/'+repMap.get(repName)+'?csv=1&isdtp=p1'); 
                ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; 
                cVersion.Origin = 'H';
                cVersion.PathOnClient = 'document3.csv';
                cVersion.OwnerId = UserInfo.getUserId();
                cVersion.Title = 'documentdel';
                
                String fileName = repName+' '+system.now()+'.csv';
                fileName = fileName.replace(' ', '_');
                fileName = fileName.replace(':', '_');
                
                if(Test.isRunningTest()) { 
                    cVersion.VersionData = blob.valueOf('Unit.Test');
                } else {
                    cVersion.VersionData = report.getContent();
                }
                calloutD(cVersion.VersionData, fileName, '');               
            }
    }
    
    public static void calloutD(blob versionData, String fileName, string tokenParam) {
        Sharepoint__c spObj = getToken();
        if(tokenParam!='') {
            system.debug('1');
            spObj.AccessToken__c = tokenParam;
        }  
        HttpRequest httpRequestToSend = new HttpRequest(); 
        
httpRequestToSend.setEndpoint('https://brainselltech.sharepoint.com/sites/TestSiteB1/_api/web/GetFolderByServerRelativeUrl(\'/sites/TestSiteB1/Shared%20Documents/Fol1\')/Files/add(url=\''+fileName+'\',overwrite=true)');        httpRequestToSend.setMethod('POST');
        httpRequestToSend.setHeader('Authorization', 'Bearer ' + spObj.AccessToken__c);
        
        httpRequestToSend.setHeader('Content-Type', 'application/json;odata=verbose');
        httpRequestToSend.setBodyAsBlob(versionData);
        Http http = new Http();
        HttpResponse httpResponse = http.send(httpRequestToSend);
        String updatedToken = '';
        if(httpResponse.getStatusCode()==401) {
            updatedToken = getNewToken();
            calloutD(versionData, fileName, updatedToken);
            spObj.AccessToken__c = updatedToken;
            system.debug('-401-');
        }
        saveToken(spObj);
        System.debug('***** Last Response-->' + httpResponse);
    }
    
    public static Sharepoint__c getToken() {
        Sharepoint__c spObj = [SELECT Id, AccessToken__c from Sharepoint__c LIMIT 1];
        return spObj;
    }
    
    public static void saveToken(Sharepoint__c spObj) {
        update spObj;
    }
    
    public static String getNewToken() {
        HttpRequest httpRequestToSend = new HttpRequest();
        
        httpRequestToSend.setEndpoint('https://accounts.accesscontrol.windows.net/e330cfd2-d4d5-4fc9-81c6-a42d71ad09ce/tokens/OAuth/2');    
        httpRequestToSend.setMethod('POST');
        httpRequestToSend.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String clientId = 'c8c0295c-1804-4d02-b521-7ef02083848e@e330cfd2-d4d5-4fc9-81c6-a42d71ad09ce';
        string clientSecret = 'qwCv3jtPfb3p9+l0t0c+b5FDt1nF0Thi1XOW2ousNA8=';
        string resourceToken = '00000003-0000-0ff1-ce00-000000000000/brainselltech.sharepoint.com@e330cfd2-d4d5-4fc9-81c6-a42d71ad09ce';
        String payload = 'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+'&resource='+EncodingUtil.urlEncode(resourceToken,'UTF-8')+'&grant_type=client_credentials';
        
        httpRequestToSend.setBody(payload);   
        Http http = new Http();   
        HttpResponse httpResponse = http.send(httpRequestToSend);
        System.debug('***** Auth Response-->' + httpResponse.getBody());
        
        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
        return (String)responseMap.get('access_token');
    }
    
    global void finish(Database.BatchableContext BC){
    }
}
@istest
public class TestScheduleReport {

    @istest
    static void method1() {   
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account acc = new Account();
        acc.name = 'test';
        insert acc;
        Test.startTest();
        ScheduleApex sap = new ScheduleApex();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Report Exporter', sch, sap);
        Test.stopTest();
       
    }
    
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}
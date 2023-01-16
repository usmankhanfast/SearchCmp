public class CustomSearchController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getSearchableObjects() {
        List<String> customSObjectList = new List<String>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values())
        {
            Schema.DescribeSObjectResult describeSObjectResultObj = objTyp.getDescribe();
            if(describeSObjectResultObj.isCustom())
            {
                String name = objTyp.getDescribe().getName();
                if(!name.containsignorecase('history') && !name.containsignorecase('tag')&&
                   !name.containsignorecase('share') && !name.containsignorecase('feed'))
                {
                    customSObjectList.add(name);
                }
            }
        }
        customSObjectList = getStandardObjects(customSObjectList);
        return customSObjectList;
    }
    
    public static List<String> getStandardObjects(List<String> customObjectList) {
        customObjectList.add('Account');
        customObjectList.add('Contact');
        customObjectList.add('Lead');
        customObjectList.add('Opportunity');
        customObjectList.add('Quote');
        customObjectList.add('Case');
        customObjectList.add('Task');
        customObjectList.add('Invoice');
        customObjectList.add('Contract');
        customObjectList.add('Order');
        customObjectList.add('Product');
        customObjectList.add('Payment');
        return customObjectList;
    }
    @AuraEnabled
    public static Map<String, String> getFieldsMeta (String sObjectName) {
        Map<String, String> mapOfFieldsMeta = new Map<String, String>();
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(sObjectName);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        
        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();
            mapOfFieldsMeta.put(String.valueOf(field), String.valueOf(F.getLabel()+'*'+F.getType()));
        }
        return mapOfFieldsMeta;
    }
}
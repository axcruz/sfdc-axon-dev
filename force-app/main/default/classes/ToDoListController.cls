public with sharing class ToDoListController {
    
    @AuraEnabled(cacheable=true)
    public static List<To_Do__c> getToDoList(Id userId){
        return [SELECT Id, Name, Contact__c, Contact__r.Name, Actions__c, Status__c, CreatedDate, CreatedById 
                FROM To_Do__c  WHERE CreatedById =: userId
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC 
                LIMIT 1000];          
    }
}
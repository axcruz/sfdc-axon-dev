@isTest private class ToDoListControllerTest {
    
    @isTest static void testGetToDoList() {
        
        Account acct = new Account(Name = 'TEST ACCT');
        insert acct;
        
        Contact con = new Contact(AccountId = acct.Id, FirstName = 'TEST', LastName='CONTACT');
        insert con;
        
        List<To_Do__c> tdList = new List<To_Do__c>();
        for(Integer i = 0; i < 200; i++) {
            tdList.add(
                new To_Do__c(Name = 'TEST' + i, Contact__c = con.Id, Actions__c = 'Action 1;', Status__c = 'To Do')
            );
        }
        insert tdList;
        
        Test.startTest();
        
        List<To_Do__c> result = ToDoListController.getToDoList(UserInfo.getUserId());
        
        Test.stopTest();
        
        System.assertEquals(200, result.size(), 'ERROR: Unexpected number of To Do records returned.');   
    }
}
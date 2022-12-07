@isTest private class ContactTriggerTest {
    
    @isTest static void testContactApproval() {
        Account acct = new Account(Name = 'TEST ACCOUNT');
        insert acct;
        
        Contact con = new Contact(AccountId = acct.Id, FirstName = 'TEST', LastName='CONTACT');
        insert con;
    }
    
}
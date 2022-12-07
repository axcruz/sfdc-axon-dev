trigger ContactTrigger on Contact (before insert, after insert, before update, after update, after delete) {
    
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            // Process before insert
        } else if (Trigger.isAfter) {
            // Process after insert
            for (Contact c: Trigger.new) {
                
                // Create an approval request for the Contact
                Approval.ProcessSubmitRequest req = 
                    new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval of newly created Contact.');
                req.setObjectId(c.Id);
                
                // Submit on behalf of Concact Owner
                req.setSubmitterId(c.OwnerId); 
                
                // Submit the record to the New Contact Approval Process
                req.setProcessDefinitionNameOrId('New_Contact_Approval_Process');
                req.setSkipEntryCriteria(true);
                
                // Submit the approval request for the Account
                Approval.ProcessResult result = Approval.process(req);
                
                // Verify the result
                System.assert(result.isSuccess());
            }      
        }        
    }
    else if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            
        } else if (Trigger.isAfter) {
            
            // Map of Account Id to Total Contact delta values 
            Map<Id, Integer> acctDeltaMap = new Map<Id, Integer>();
            // Set to hold parent Account Ids 
            Set<Id> acctIdSet = new Set<Id>();
            
            for (Contact c : Trigger.new) {
                // Add parent Account Id to Account Id set for reference
                acctIdSet.add(c.AccountId);  
                // Get the existing delta value, if none is found instantiate at 0
                Integer countDelta = acctDeltaMap.get(c.AccountId) == null ? 0 : acctDeltaMap.get(c.AccountId);
                // Check if Active has been changed 
                if (Trigger.oldMap.get(c.Id).Active__c != c.Active__c ) {
                    if (c.Active__c == true) {
                        // Increment the delta
                        countDelta += 1;
                    } else {
                        // Decrement the delta
                        countDelta -= 1;
                    }
                }
                // Add the incremented delta back the Account Id to delta map
                acctDeltaMap.put(c.AccountId, countDelta);
            }
            // Query for the parent Accounts
            List<Account> acctUpdateList = [SELECT Id, Total_Contacts__c FROM Account WHERE Id IN :acctIdSet];
            // Add the deltas to the current Total Contacts to the parent Accounts 
            system.debug(acctDeltaMap);
            for(Account acct: acctUpdateList) {
                system.debug(acct.Id);
                system.debug(acctDeltaMap.get(acct.Id));
                if (acct.Total_Contacts__c == null) {
                    acct.Total_Contacts__c = acctDeltaMap.get(acct.Id);
                } else {
                    acct.Total_Contacts__c += acctDeltaMap.get(acct.Id);
                }
            }
            // Update the parent Accounts
            update acctUpdateList;
            
        }
    }
    else if (Trigger.isDelete) {
        // Process after delete
        if (Trigger.isAfter) {
            
            // Map of Account Id to Total Contact delta values 
            Map<Id, Integer> acctDeltaMap = new Map<Id, Integer>();
            // Set to hold parent Account Ids 
            Set<Id> acctIdSet = new Set<Id>();
            
            for (Contact c : Trigger.old) {
                // Add parent Account Id to Account Id set for reference
                acctIdSet.add(c.AccountId);  
                // Get the existing delta value, if none is found instantiate at 0
                Integer countDelta = acctDeltaMap.get(c.AccountId) == null ? 0 : acctDeltaMap.get(c.AccountId);
                // Check if Active
                if (c.Active__c == true) {
                        // Decrement the delta
                        countDelta -= 1;
                    }
                
                // Add the incremented delta back the Account Id to delta map
                acctDeltaMap.put(c.AccountId, countDelta);
            }
            // Query for the parent Accounts
            List<Account> acctUpdateList = [SELECT Id, Total_Contacts__c FROM Account WHERE Id IN :acctIdSet];
            // Add the deltas to the current Total Contacts to the parent Accounts 
            for(Account acct: acctUpdateList) {
                if (acct.Total_Contacts__c != null) {
                    acct.Total_Contacts__c += acctDeltaMap.get(acct.Id);
                }
            }
            // Update the parent Accounts
            update acctUpdateList;
            
        }
    }
}
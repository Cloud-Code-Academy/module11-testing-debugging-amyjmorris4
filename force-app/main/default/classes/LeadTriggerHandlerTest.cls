@isTest
public with sharing class LeadTriggerHandlerTest {

    @TestSetup
    static void setupData(){

        //Create Account for the Contact in the test
        Account testAccount = new Account(Name = 'TestAccount');
        insert testAccount;

        //Create a Contact associated with the Account
        Contact matchingContact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@test.com', AccountId = testAccount.Id);
        insert matchingContact;

        //Create test Leads
        Lead testLead1 = new Lead(FirstName = 'John', LastName = 'Doe', Company = 'TestCorp', Email = 'john.doe@test.com', Title = 'vp', Phone = '1234567890', LeadSource = 'Website', Industry = 'Technology');
        Lead testLead2 = new Lead(FirstName = 'Jane', LastName = 'Smith', Company = 'ExampleCorp', Email = 'jane.smith@example.com', Title = 'exec', Phone = null, LeadSource = 'Referral', Industry = 'Finance');
        insert new List<Lead> { testLead1, testLead2 };
    }

    @isTest
    static void testHandleTitleNormalization() {
        //Retreive test data
        List<Lead> leads = [SELECT Id, Title FROM Lead];

        //Run the title normalization method
        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(leads);
        Test.stopTest();

        //Assert title changes
        System.assertEquals('Vice President', leads[0].Title, 'Title should be normalized to "Vice President"');
        System.assertEquals('Executive', leads[1].Title, 'Title should be normalized to "Executive"');
    }
    @isTest
    static void testHandleAutoLeadScoring() {
        List<Lead> leads = [SELECT Id, Lead_Score__c, LeadSource, Email, Phone, Industry FROM Lead];

        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leads);
        Test.stopTest();

        //Assert lead scoring
        System.assertEquals(18, leads[0].Lead_Score__c, 'Lead score should be 18 for Lead 1');
        System.assertEquals(0, leads[1].Lead_Score__c, 'Lead score should be 0 for Lead 2');

    }

    @isTest
    static void testHandleLeadAutoConvert() {
        //Retreive the test Lead with the email that matches the contact
        List<Lead> leads = [SELECT Id, Email, IsConverted FROM Lead WHERE Email = 'john.doe@test.com'];
        
        /*Contact matchingContact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@test.com');
        insert matchingContact;

        List<Lead> leads = [SELECT Id, Email, IsConverted FROM Lead WHERE Email = 'john.doe@test.com'];*/

        Test.startTest();
        LeadTriggerHandler.handleLeadAutoConvert(leads);
        Test.stopTest();

        //Assert lead conversion
        Lead convertedLead = [SELECT IsConverted FROM Lead WHERE Id = :leads[0].Id];
        System.assertEquals(true, convertedLead.IsConverted, 'Lead should be converted');

    }
} 
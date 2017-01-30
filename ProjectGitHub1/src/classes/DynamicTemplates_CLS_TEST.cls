@isTest
public class DynamicTemplates_CLS_TEST {
    static testMethod void test1(){
        //Insert Account, Contact Case
        Account a = new Account();
        a.name = 'Test Account';
        a.billingStreet = 'sample street';
        a.billingcity = 'sample city';
        a.billingcountry = 'sample country';
        Insert a;
        System.debug('##########Account Inserted: '+ a);
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.AccountId = a.Id;
        con.Email = 'testmail@mail.com';
        Insert con;
        System.debug('##########Contact Inserted: '+ con);
        Case c = new Case();
        c.Origin = 'Web';
        c.Status = 'New';
        c.AccountId = a.Id;
        c.ContactId = con.Id;
        Insert c;
        System.debug('##########Case : '+ c);


        PageReference pageRef = Page.Dyna_ListTemplates;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('param',con.Id); 
        DynamicTemplates_CLS dyt = new DynamicTemplates_CLS();
        dyt.gettemps();
        dyt.getSelected();
        dyt.Previous();
        dyt.Beginning();
        dyt.Next();
        dyt.last();
        dyt.getDisablePrevious();
        dyt.getDisableNext();
        dyt.getTotal_size();
        dyt.getPageNumber();
        dyt.getTotalPages();
    }
}
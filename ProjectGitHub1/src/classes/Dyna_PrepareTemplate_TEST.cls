@isTest
public class Dyna_PrepareTemplate_TEST{
    static testMethod void test1(){
        List<Case> cL = new List<Case>();
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
        for(Integer i=0; i<5; i++){
            Case c = new Case();
            c.Origin = 'Web';
            c.Status = 'New';
            c.AccountId = a.Id;
            c.ContactId = con.Id;
            cL.add(c);
            System.debug('##########Case : GATTU==>'+c);
        }
        Insert cL;
        System.debug('##########Case : '+ cL.size()+'GATTU==>'+cL);
        //Insert Dynamic Template
        DynamicTemplate__c dt = new DynamicTemplate__c();
        dt.Name = 'SampleTemplate';
        dt.Description__c = 'For testing';
//      dt.html_body__c = '<html> <head> <title>Sample Template</title> <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" type="text/css" media="screen"/> <style type="text/css"> .bs-dropzone { border: 2px dashed #eee; border-radius: 4px; color: #777; margin: 25px; position: relative; padding: 10px; } .panel { margin: 20 !important; } .panel-body, table {font-size: 12px;} </style> </head> <body> <div class="container"> <div class="panel panel-success"> <div class="panel-heading"> <h3 class="panel-title">#1 Base object fields examples</h3> </div> <div class="row"> <div class="col-md-5 bs-dropzone"> <span style="font-weight:bold;text-decoration: underline; color: green;">Placeholder Syntax</span> <div class="panel-body"> Hello [!Order__r.Account.Name] <br/> Address: <p style="font-family:Arial;font-size:12px;"> [!Order__r.Account.BillingStreet]&nbsp;&nbsp;[!Order__r.Account.BillingCity]<br/> [!Order__r.Account.BillingPostalCode]<br/> [!Order__r.Account.BillingCountry] </p> </div> </div> <div class="col-md-5 bs-dropzone"> <span style="font-weight:bold;text-decoration: underline; color: green;">Placeholder replaced with values:</span> <div class="panel-body"> Hello <b>{!Order__r.Account.Name}</b> <br/> Address: <p style="font-family:Arial;font-size:12px;"> {!Order__r.Account.BillingStreet}&nbsp;&nbsp;{!Order__r.Account.BillingCity}<br/> {!Order__r.Account.BillingPostalCode}<br/> {!Order__r.Account.BillingCountry} </p> </div> </div> </div> </div> <!-- Block2 --> <div class="panel panel-success"> <div class="panel-heading"> <h3 class="panel-title">#2 Base object fields with conditions</h3> </div> <div class="row"> <div class="col-md-5 bs-dropzone"> <span style="font-weight:bold;text-decoration: underline; color: green;">Placeholder Syntax</span> <div class="panel-body"> Carset Num: [!Rfleet_Car_set_Number__c@where#NumberOfUnitOrders__c = 3] <br/> VAT Code: [!VATCode__c@where#NumberOfUnitOrders__c > 5] </div> </div> <div class="col-md-5 bs-dropzone"> <span style="font-weight:bold;text-decoration: underline; color: green;">Placeholder replaced with values:</span> <div class="panel-body"> Carset Num: <b>{!Rfleet_Car_set_Number__c@where#NumberOfUnitOrders__c = 3}</b> <br/> VAT Code: <b>{!VATCode__c@where#NumberOfUnitOrders__c > 5}</b> </div> </div> </div> </div> <!-- Block 3--> <div class="panel panel-success"> <div class="panel-heading"> <h3 class="panel-title">#3 Parent to child fields examples</h3> </div> <div class="row"> <div class="col-md-5 bs-dropzone"> <span style="font-weight:bold;text-decoration: underline; color: green;">Placeholder Syntax</span> <div class="panel-body"> <span style="text-decoration: underline;">Single Field:</span> <table cellspacing=6> <tr><td>Service Label</td></tr> <tr> <td></td> </tr> </table> <br/> <span style="text-decoration: underline;">Multiple Fields:</span> <table cellspacing=6> <tr> <td colspan=2>[!SRV_Service__c.Label__c, SRV_Service__c.PriceHT__c@lists#]</td> </tr> </table> </div> </div> <div class="col-md-5 bs-dropzone"> <span style="font-weight:bold;text-decoration: underline; color: green;">Placeholder replaced with values:</span> <div class="panel-body"> <span style="text-decoration: underline;">Single Field:</span> <table cellspacing=6> <tr><td>Service Label</td></tr> <tr> <td></td> </tr> </table> <br/> <span style="text-decoration: underline;">Multiple Fields:</span> <table cellspacing=6> <tr> <td colspan=2>{!SRV_Service__c.Label__c, SRV_Service__c.PriceHT__c@lists#}</td> </tr> </table> </div> </div> </div> </div> <!-- Block 4--> <div class="panel panel-success"> <div class="panel-heading"> <h3 class="panel-title">#4 Parent to child fields with condition</h3> </div> <div class="row"> <div class="col-md-5 bs-dropzone"> <span style="font-weight:bold;text-decoration: underline; color: green;">Placeholder Syntax</span> <div class="panel-body"> <span style="text-decoration: underline;">Single Field:</span> <table cellspacing=6> <tr><td>Service Label</td></tr> <tr> <td>[</td> </tr> </table> <br/> <span style="text-decoration: underline;">Multiple Fields:</span> <table cellspacing=6> <tr> <td colspan=2> [!SRV_Service__c.Label__c, SRV_Service__c.PriceHT__c@lists#@where#Code__c=\'PC4\'] </td> </tr> </table> </div> </div> <div class="col-md-5 bs-dropzone"> <span style="font-weight:bold;text-decoration: underline; color: green;">Placeholder replaced with values:</span> <div class="panel-body"> <span style="text-decoration: underline;">Single Field:</span> <table cellspacing=6> <tr><td>Service Label</td></tr> <tr> <td></td> </tr> </table> <br/> <span style="text-decoration: underline;">Multiple Fields:</span> <table cellspacing=6> <tr> <td colspan=2>{!SRV_Service__c.Label__c, SRV_Service__c.PriceHT__c@lists#@where#Code__c=\'PC4\'}</td> </tr> </table> </div> </div> </div> </div> <!-- Block 5--> <div class="panel panel-success"> <div class="panel-heading"> <h3 class="panel-title">#5 Direct queries:</h3> </div> <div class="row"> <div class="col-md-5 bs-dropzone"> <span style="font-weight:bold;text-decoration: underline; color: green;">Placeholder Syntax</span> <div class="panel-body"> [!@fields# VINNumber__c,VehicleOrderNumber__c @query# Select VINNumber__c, VehicleOrderNumber__c from VEH_Vehicle__c where UnitOrder__r.CarSet__c = @baseObjectId#] </div> </div> <div class="col-md-5 bs-dropzone"> <span style="font-weight:bold;text-decoration: underline; color: green;">Placeholder replaced with values:</span> <div class="panel-body"> {!@fields# VINNumber__c,VehicleOrderNumber__c @query# Select VINNumber__c, VehicleOrderNumber__c from VEH_Vehicle__c where UnitOrder__r.CarSet__c = @baseObjectId#} </div> </div> </div> </div> <!-- Block 6 --> <div class="panel panel-success"> <div class="panel-heading"> <h3 class="panel-title">#6 Special fields examples</h3> </div> <div class="row"> <div class="col-md-5 bs-dropzone"> <span style="font-weight:bold;text-decoration: underline; color: green;">Placeholder Syntax</span> <div class="panel-body"> Current Date: <b>[!@currentDate#]</b> </div> </div> <div class="col-md-5 bs-dropzone"> <span style="font-weight:bold;text-decoration: underline; color: green;">Placeholder replaced with values:</span> <div class="panel-body"> Current Date: <b>{!@currentDate#}</b> </div> </div> </div> </div> </div> </body> </html>';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
        dt.HtmlBody__c = '<html><body>ParentToChild: {!Case.Id, Case.Status, Case.AccountId@lists#}......PtoC with Condition {!Case.Id, Case.Status, Case.AccountId@lists#@where#Status=\'New\'} ------------------Hellow Contact Fields:{!Id}{!LastName}{!FirstName} ......Con With Conditions:{!Email@where#Email = \'testmail@mail.com\'} ---------Account Fields-------- {!Account.Name}{!Account.BillingAddress} -------------DirectQuery {!@fields#LastName@query#select LastName from Contact where CarSet__c = @baseObjectId# Limit 1}---------------SpecialFieldsCurrent Date: {!@currentDate#}......Exception1 {!Case.Id, Case.Stats, Case.AccountId@lists#@where#Status=\'New\'}.......What fields: {!What.Account.Name}......Exception2{!Case.Id, Case.Stats, Case.AccountId@lists#@where#Status=\'New\'}</body></html>';
        dt.HTMLHeader__c = '';
        dt.RelatedObject__c = 'Contact';
        dt.Version__c = '1.0';
        Insert dt;
        PageReference pageRef = Page.Dyna_ListTemplates;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('tmpId',dt.Id);
        ApexPages.currentPage().getParameters().put('ptype','asPdf'); 
        ApexPages.currentPage().getParameters().put('param',con.Id);//baseObjectRecordId 
        
        //ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(emp);
        Dyna_PrepareTemplate dpt = new Dyna_PrepareTemplate();
        System.debug('@@@@@@@@@@@ TemplateId: '+dpt.templateId );
        System.debug('@@@@@@@@@@@ ObjectId: '+dpt.objectId );
        System.debug('@@@@@@@@@@@ ObjectName: '+dpt.objectName );
        dpt.renderTemplate();
        dpt.getChooserender();
        dpt.saveTemplate();
        
        Dyna_TemplateHelper dth = new Dyna_TemplateHelper();
        dth.getFields('Contact');
        dth.getChildren('Contact');
        
        System.debug('########Test method Exit');
    }
    
    static testMethod void Dyna_DisplayRecordstest1(){
        Dyna_DisplayRecords dispRec = new Dyna_DisplayRecords();
        //    dynaListing(List<List<String>> records, List<String> labels, Integer numberOfCols) 
        //List of Lists
        List<List<String>> outerList = new List<List<String>>();

        List<String> innerList1 = new List<String>();
        innerList1.add('Value1 1');
        innerList1.add('Value1 2');
         
        List<String> innerList2 = new List<String>();
        innerList2.add('Value2 1');
        innerList2.add('Value2 2');
         
        outerList.add(innerList1);
        outerList.add(innerList2);
        
        //Labels
        List<String> displabels = new List<String>();
        displabels.add('Label 1');
        displabels.add('Label 2');
        
        dispRec.dynaListing(outerList,displabels, 5);
    }
}
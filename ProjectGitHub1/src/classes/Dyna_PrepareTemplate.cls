public Class Dyna_PrepareTemplate 
{
    public String objectId{get;set;}
    public String objectName{get;set;}
    public String templateId{get;set;}
    public String cssCode{get;set;}
    public String htmlCode {
      get { return htmlCode; }
      set { htmlCode = value; }
    }
    public Dyna_TemplateHelper helper = new Dyna_TemplateHelper();
    Public String pType {get; set;}
    public String handsonTableData {
        get { return handsonTableData; }
        set { handsonTableData = value; }
    }
    public String myString {get; set;}
    public Dyna_BackupTemplate__c bTemplate {get; set;}
    public Dynamictemplate__c pt = new Dynamictemplate__c();

    public String getChooserender() {
      if (ApexPages.currentPage().getParameters().get('ptype') == 'asPdf')
        return 'pdf';
      else
        return null;
    }    
    
    public Dyna_PrepareTemplate() {
        templateId = apexpages.currentpage().getparameters().get('tmpId');
        pType = apexpages.currentpage().getparameters().get('pType');
        
        System.debug('###Dyna_PrepareTemplate - Constructor - Param: 1. templateId --> '+ templateId);
        System.debug('###Dyna_PrepareTemplate - Constructor - Param: 2. pType --> '+ pType);
      
        pt = [SELECT Id, Name, relatedobject__c, HTMLHeader__c, htmlbody__c FROM dynamictemplate__c where Id  = :templateId  limit 1];
        if (apexpages.currentpage().getparameters().get('showBackupTempalte') == 'yes') {
            Dyna_BackupTemplate__c qBackupTemplate = [SELECT Id, html_body__c FROM Dyna_BackupTemplate__c where DynamicTemplateId__c  = :templateId  limit 1];
            htmlCode = qBackupTemplate.html_body__c;
        }
        else {
            htmlCode =  pt.htmlbody__c;
        }
        //Setting Required Data's in constructor
        objectId = apexpages.currentpage().getparameters().get('param');
        objectName = helper.findObjectNameById(objectId);
        helper.baseObjectId  = objectId;
        helper.pTemplateId  = templateId;
        helper.baseObjectName = objectName;
        System.debug('###objectId: ' + objectId + ' templateId:' + templateId);        
        
        //To Manage data with respect to backupTemplate
        bTemplate = new Dyna_BackupTemplate__c();
    }
     
   /**
     * Main method to render template
     * Includes all rendering logic by handling diff scenarios
   **/
    public void renderTemplate() {
        try {
                /*String pv0=apexpages.currentpage().getparameters().get('pv0');
                 Map<String, String> urlParams = new Map<String, String>();                 
                urlParams.put('pv0',pv0);
                htmlCode = helper.replaceUrlParams(urlParams, htmlCode);
                System.debug('#htmlCode param replace'+htmlCode);*/
                
           //STEP 0: replacing dyna params if any
           Map<String,String> dynaParams = new Map<String,String>();              
           dynaParams=apexpages.currentpage().getparameters();         
             System.debug('###dynaParams'+dynaParams);                    
             System.debug('###dynaParams to replace'+dynaParams);                       
                 if(!dynaParams.isEmpty())
                    {
                     htmlCode = helper.replaceUrlParams(dynaParams,htmlCode);                     
                 
                    }                
             
            
             
        
            //STEP1: Getting all placeholders from html template content
            Map<String, String> placeHolders = helper.getPlaceHolders(htmlCode);
            
            //STEP2: Catagorize diffrent types of placeholders
            Map<String, List<String>> placeholderTypes = helper.identifyFieldType(placeHolders);
            System.debug('###renderTemplate:###' + placeholderTypes);
            
            //Treating Special fields such as currentDate
            Map<String, String> specialFieldsWithValue = helper.manageSpecialFields(placeholderTypes.get('specialFields'));
            if (!specialFieldsWithValue.isEmpty()) {
                htmlCode = helper.replaceHtmlCode(specialFieldsWithValue, htmlCode);
            }
            
            //STEP3: Manage baseObjectFields
            Map<String, String> baseObjFieldsWithValue = helper.manageBaseObjectFields(placeholderTypes.get('baseObjFields'));
            if (!baseObjFieldsWithValue.isEmpty()) {
                htmlCode = helper.replaceHtmlCode(baseObjFieldsWithValue, htmlCode);
            }
            
            //STEP4: Manage baseObjectFields
            Map<String, String> baseObjFieldsAndCondWithValue = helper.manageBaseObjFieldsWithCond(placeholderTypes.get('baseObjFieldsWithCond'));
            if (!baseObjFieldsAndCondWithValue.isEmpty()) {
                htmlCode = helper.replaceHtmlCode(baseObjFieldsAndCondWithValue, htmlCode);
            }
            
            //STEP5: Manage parent to child fields
             Map<String, String> pToCFieldsWithValue = helper.managePToCFields(placeholderTypes.get('pToCFields'));
             if(!pToCFieldsWithValue.isEmpty()) {
                 htmlCode = helper.replaceHtmlCode(pToCFieldsWithValue, htmlCode);
             }
            
            //STEP6: Manage parent to child fields with conditions
             Map<String, String> pToCWithCondFieldsWithValue = helper.managePToCFieldsWithCond(placeholderTypes.get('pToCFieldsWithCond'));
             if(!pToCWithCondFieldsWithValue.isEmpty()) {
                 htmlCode = helper.replaceHtmlCode( pToCWithCondFieldsWithValue, htmlCode);
             }
             
             //STEP7: Manange direct queries
            Map<String, String> directQueryResults = helper.manageDirectQueries(placeholderTypes.get('directQueries'));
            if(!directQueryResults.isEmpty()) {
                 htmlCode = helper.replaceHtmlCode(directQueryResults, htmlCode);
            }
            
            //STEP8: Manange Events, Tasks related fields ('What.' fields)
            Map<String, String> whatTypeResults = helper.manageWhatTypeFields(placeholderTypes.get('whatFields'));
            System.debug('##### Deva -- PrepareTemplace --> whatTypeResults: ' + whatTypeResults);
            if(!whatTypeResults.isEmpty()) {
                 htmlCode = helper.replaceHtmlCode(whatTypeResults, htmlCode);
            }
            
            this.handsOnTableData = Json.SerializePretty(helper.helperHandsonTableData);
            System.debug('HandsonTable Value in Prepare Temp: ' + this.handsOnTableData);
        } catch (exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Error in templates: ' + e));
        }
    }
       
    public PageReference saveTemplate() {
        String tmpId = ApexPages.CurrentPage().getParameters().get('tmpId');
        String recordId = ApexPages.CurrentPage().getParameters().get('param');
        String viewType = ApexPages.CurrentPage().getParameters().get('ptype');
        String reqViewType = ApexPages.CurrentPage().getParameters().get('reqViewType');
        
        //Assigning viewType
        if(reqViewType != '') {
            viewType = reqViewType;
            System.debug('###SaveTemplate - viewType' + viewType);
        }

        List<Dyna_BackupTemplate__c> exsTemplateObj;
        Dyna_BackupTemplate__c bNewTemplateObj = new Dyna_BackupTemplate__c();
        if (tmpId != null) {
            exsTemplateObj = [Select Id, Name, DynamicTemplateId__c, html_body__c, Status__c from Dyna_BackupTemplate__c where DynamicTemplateId__c =: tmpId LIMIT 1];   

            bNewTemplateObj.Name = pt.Name;
            bNewTemplateObj.html_body__c = bTemplate.html_body__c;
            bNewTemplateObj.DynamicTemplateId__c = tmpId;
            if (viewType == 'Print') {
                bNewTemplateObj.Status__c = 'Printed';
            }
            if (exsTemplateObj.size() == 0 && (viewType == 'Preview' || viewType == 'asPdf')) {
                bNewTemplateObj.Status__c = 'Draft';
            }
            if (exsTemplateObj.size() > 0) {
                bNewTemplateObj.Id = exsTemplateObj[0].Id;
                if (exsTemplateObj[0].Status__c == 'Printed') {
                    bNewTemplateObj.Status__c = 'Printed';
                }   
            }
        }
        try {
            System.debug('### SaveTemplate: bNewTemplateObj: ' + bNewTemplateObj);
            upsert bNewTemplateObj;
        } catch (Exception e) {
            System.debug('@@@SaveTemplate-Upsert-Exception: ' + e);
        }

        String extraParams = 'param=' + recordId + '&tmpId=' + tmpId + '&ptype=' + viewType + '&showBackupTempalte=yes';
        System.debug('###saveTemplate() -> extraParams: ' + extraParams);
        PageReference prepateTemplatePage = new PageReference('/apex/Dyna_PrepareTemplate?' + extraParams);
        prepateTemplatePage.setRedirect(true);
        return prepateTemplatePage;
    }
}
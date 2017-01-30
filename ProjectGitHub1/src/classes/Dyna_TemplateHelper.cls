Public Class Dyna_TemplateHelper {
    
    public String baseObjectId {
      get { return baseObjectId; }
      set { baseObjectId = value; }
    }   
    public String baseObjectName {
      get { return baseObjectName; }
      set { baseObjectName = value; }
    }
    
    public String pTemplateId {
      get { return pTemplateId; }
      set { pTemplateId = value; }
    }

    public List<List<String>> helperHandsonTableData {
        get { return helperHandsonTableData; }
        set { helperHandsonTableData = value; }
    }   
        
    Private String startSeparator = '{!';
    Private String endSeparator = '}';
    Private String whereIdentifier = '@where#';
    Private String listIdentifier = '@lists#';
    Private String queryIdentifier= '@query#';
    Private String fieldsIdentifier= '@fields#';
    Private String baseObjectIdIdentifier = '@baseObjectId#';
    Private String pTemplateIdentifier = '@templateId#';
    Private String spclWhatDotIdentifier = 'What.';
    public String labelIdentifier='@labels#';
    public String optionsIdentifier = '@options#';
    
    private static Boolean stateAndCountryPickersEnabled = false;
    Public  String dot = '.';
    Public  String comma = ',';
    Public  Integer globalQueryLimit = 1000;
    public String dateFormat = 'dd/MM/YYYY';
    Public List<String> hideIds{get;set;}
    
    /**
     * Constructor
    **/ 
    Public Dyna_TemplateHelper() {
        System.debug('###Template Helper Constructor Called###');    
    }
    
    /**
     * Gets all place holders as Map
    **/
    Public Map<String, String> getPlaceHolders(String initialHtml) {
        integer i = 0;
        String templateBody = initialHtml;
        String holderKey;
        String fieldName;
        
        Map<String, String> placeHolders = new Map<String, String>();
        while(templateBody.contains(startSeparator)) {
            i++;
            String tmp = templateBody.substringAfter(startSeparator);
            fieldName = tmp.substringbefore(endSeparator);
            holderKey = startSeparator + fieldName + endSeparator;
            placeHolders.put('#@#'+i+'#', fieldName);
            templateBody = templateBody.replace(holderKey, '#@#'+i+'#');
        }
        System.debug('###List of placeHolders:###' + placeHolders);
        return placeHolders;
    }
    
    /**
     * Identify different scenarios in placeholders
     * @input Map<String, String> fields
     * @output Map<String, List<String>> Different types of placeholders
    **/
    Public Map<String, List<String>> identifyFieldType(Map<String, String> fields) {
        List<String> baseObjFields = new List<String>();
        List<String> baseObjFieldsWithCond = new List<String>();
        
        List<String> pToCFieldsWithCond = new List<String>();
        List<String> pToCFields = new List<String>();
        
        List<String> directQueries = new List<String>();
        List<String> specialFields = new List<String>();
        List<String> whatFields = new List<String>();

        //Parsing each fields and identifying the pattern
        List<String> allFields = new List<String>();
        allFields = fields.values();
        for (String eachField : allFields) {
            //@#where
            eachField = eachField.trim();
            if (eachField.contains('@currentDate#')) {
                specialFields.add(eachField);
            } else if (eachField.containsIgnoreCase(spclWhatDotIdentifier)) {
                whatFields.add(eachField);
            }
            else if (eachField.contains('@query#')) {
                directQueries.add(eachField);
            }
            else if (eachField.contains('@lists#')) {
                if (eachField.contains(whereIdentifier)) {
                    pToCFieldsWithCond.add(eachField);
                } else {
                    pToCFields.add(eachField);
                }
            }
            else {
                if (eachField.contains(whereIdentifier)) {
                    baseObjFieldsWithCond.add(eachField);
                } else {
                    baseObjFields.add(eachField);
                }
            }
        }
        
        Map<String, List<String>> placeholderTypes = new Map<String, List<String>>();
        placeholderTypes.put('baseObjFields', baseObjFields);
        placeholderTypes.put('baseObjFieldsWithCond', baseObjFieldsWithCond);
        placeholderTypes.put('pToCFields', pToCFields);
        placeholderTypes.put('pToCFieldsWithCond', pToCFieldsWithCond);
        placeholderTypes.put('directQueries', directQueries);
        placeholderTypes.put('specialFields', specialFields);
        placeholderTypes.put('whatFields', whatFields);        
        System.debug('###placeholderTypes'+ placeholderTypes);
        return placeholderTypes;
    }
   
    /**
     * builds and execute base object query and returns sObject as query result 
    **/
    public sObject buildAndExecuteQuery(List<String> fields, String qObject, String condition) {
        String cond = '';
        String qFields = listToString(fields);
        Sobject qResult;
        String qLimit = '';
        
        try {
            if (condition != null) {
                cond = ' Where ' + condition;
                String tmpCond = cond.toLowerCase();
                if (!tmpCond.contains('limit')) {
                    qLimit = ' Limit ' + globalQueryLimit;
                }
            }
            
            String q = 'Select ' + qFields + ' From ' + qObject + cond + qLimit;
            System.debug('###buildAndMapQueryResult: query->###' + q);
            qResult = Database.query(q);
            System.debug('###qResult###' + qResult);
        } catch (Exception e) {
            System.debug('###Error processing query:###' + e.getMessage());
        }
        return qResult;
    }
    
   /*
    *   builds and execute parent to child query and returns sObject as query result 
   **/
    public String buildAndExecutePToCQuery(String field, String baseObject, String condition) {
                 
        Sobject qResult;
        String html='';
        String objectWithFieldString;
        String childObjectName;
        String fieldName; 
        String childObjectPluralLabel; 
        String baseObjcond = 'id = \'' + baseObjectId + '\'';
        String parentToChildCondition='';
        String[] fieldsList=new String[]{};
        List<List<String>> resultsList = new List<List<String>>();
        List<String> labels=new List<String>();
     
        if(condition != null) {
            parentToChildCondition = ' Where ' + condition;
        }
    
        objectWithFieldString = field.substringbefore(listIdentifier);            
        System.debug('### pToC objectWithFieldString ### '+objectWithFieldString);
        
        if(objectWithFieldString.contains(comma))
        {
        fieldsList=objectWithFieldString.split('\\,');
        System.debug('###fieldsList'+fieldsList+'fieldsList size'+fieldsList.size());
        
        }
        else
        {
        fieldsList.add(objectWithFieldString);        
        
        }
        if(fieldsList.size()>0)
        {
            if(fieldsList[0].contains(dot))
            {
                String[] arr = objectWithFieldString.split('\\.');
                if(arr.size() > 0) {
                    childObjectName = arr[0];
                    System.debug('### pToC childObjectName ### '+ childObjectName);
                                  
                } 
            } 
                
                          
        }
        if(childObjectName != null) {
            childObjectPluralLabel = findChildObjectPluralLabel(childObjectName);
            System.debug('### pTOC  childObjectPluralLabel' +  childObjectPluralLabel);
        }
        
        try {
            String q = 'Select (SELECT ' + objectWithFieldString + ' From ' + childObjectPluralLabel + ' ' + parentToChildCondition + ') FROM '+baseObject+' Where '+ baseObjcond + ' Limit 20';
            System.debug('### buildAndExecutePToCQueryt : query-> ###' + q);
            qResult = Database.query(q);
            if(qResult!=null)
            {
              SObject[] children = qResult.getSObjects(childObjectPluralLabel);
              if (children != null) {
                  for (SObject childRecord : children){ 
                    List<String> record = new List<String>();
                    for(Integer i = 0; i < fieldsList.size(); i++) {
                      String childField = String.valueOf(childRecord.get(fieldsList[i].substringAfter(dot))); 
                      System.debug( 'Child Name: '+ childField );
                      record.add(childField);                      
                    }    
                    resultsList.add(record);        
                }
             }
             html = getListAsHtmlTable(resultsList,labels, null);
            }
            System.debug('### buildAndExecutePToCQuery qResult###' + qResult);
            System.debug('### buildAndExecutePToCQuery resultsList###' +resultsList );
            
        } catch (Exception e) {
            System.debug('###Error processing query:###' + e.getMessage());
        }
        return html;
    }
   
    /**
     * Input: list
     * Output: Coma separated fields as string
    **/
    public String listToString(List<String> fieldsList) {
        String comaSeparatedFields = '';
        System.debug('###listToString: fieldList -> ###'+ fieldsList);
        if (fieldsList.size() > 0) {
        System.debug('###listToString: not empty####');
            for (String eachField : fieldsList) {
                if (comaSeparatedFields != '') {
                    comaSeparatedFields = comaSeparatedFields + ', ' + eachField;
                } else {
                    comaSeparatedFields = eachField;
                }
            }
        }
        System.debug('###listToString: comaSeparatedFields###' + comaSeparatedFields);
        return comaSeparatedFields;
    }
    
    public String findObjectNameById(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        } catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
    
    /**
    * @input List<String> fields
    * @input sObject results
    *
    * @output Map<String, String> resultsMap
    **/
    public Map<String, String> replaceBaseObjectFields(List<String> fields, sObject results) 
    {
        sObject temp = results;
        sObject subResult;
        String objectType=' ';
        if(results!=null)
        {
        objectType=String.valueOf(results.getSObjectType());
        
        }
        System.debug('sobject type'+objectType);
        String finalVal = '';
        Map<String, String> mappedResult = new Map<String, String>();    
        System.debug('###replaceBaseObjectFields: Fields Size###' + fields.size()); 
        System.debug('###sobject results'+results)  ;
        try {
            if(fields.size() > 0) {
                if(results!=null) {
                    for(integer i=0; i < fields.size(); i++) {
                        System.debug('element'+i+': fieldsI-----'+ fields[i]+'----');
                        if(fields[i].contains(dot)) {
                            String[] arr = fields[i].split('\\.');
                            System.debug('arr size'+arr.size());
                            Integer lastElementIndex = (arr.size())-1;
                            System.debug('####replaceBaseObjectFields: Last element index ' + lastElementIndex + 
                            'Last element ' + arr[lastElementIndex]);
                            for(integer j = 0; j < lastElementIndex; j++) {
                                System.debug('element inside 2nd  loop '+j+' for '+fields[i]+':'+arr[j]);
                                subResult = results.getSobject(arr[j]);                               
                                System.debug('subresult inside 2 nd loop '+j+' for '+fields[i]+':'+subResult);
                                if (subResult == null) {
                                    
                                    break;
                                }
                                results = subResult;
                            }
                            results = temp;
                             String subResultType=' ';
                           
                            if(subResult != null) {
                             System.debug('###subresult object type'+subResult.getSObjectType());
                             subResultType =String.valueOf(subResult.getSObjectType());
                                //sending objectname and fieldname to get field type
                                if (this.getFieldTypeName(subResultType, arr[lastElementIndex]) == 'ADDRESS') {
                                    String address = '';
                                    String addressJson = JSON.serialize(subResult.get(arr[lastElementIndex]));
                                    System.debug('### addressJson' + addressJson);
                                    Map<String,Object> addressMap = (Map<String,Object>) JSON.deserializeUntyped(addressJson);
                                    System.debug('### addressMap' + addressMap);
                                    address=getAddress(addressMap);    
                                    finalVal=address;
                                } 
                                 else if(this.getFieldTypeName(subResultType, arr[lastElementIndex]) == 'DATE')
                                   {
                                     System.debug('###DATE FIELD'+subResult.get(arr[lastElementIndex]));
                                         if( subResult.get(arr[lastElementIndex])!=null)
                                         {
                                             Date d=(Date) subResult.get(arr[lastElementIndex]);
                                             finalVal=d.format();
                                         }
                                     System.debug('###DATE FIELD finalVal'+finalVal);
                                         
                                         
                                        
                                   }  
                                 else if(this.getFieldTypeName(subResultType,arr[lastElementIndex]) == 'DATETIME')
                                  {                                 
                                        
                                    System.debug('###DATE TIME FIELD'+subResult.get(arr[lastElementIndex]));
                                         if( subResult.get(arr[lastElementIndex])!=null)
                                         {                                          
                                         DateTime d=(DateTime) subResult.get(arr[lastElementIndex]);
                                         finalVal=d.date().format();   
                                         }  
                                    System.debug('###DATE TIME FIELD finalVal'+finalVal);
                                                            
                                        
                                   }                                                              
                                                           
                                
                                else {
                                
                                    
                                    finalVal = String.valueOf(subResult.get(arr[lastElementIndex]));
                                }
                                           
                                if (finalVal == null) {
                                    finalVal = '';
                                }
                                System.debug('###Result:' + arr[lastElementIndex] + '->' + finalVal);
                                mappedResult.put(fields[i], finalVal);
                                subResult = null;
                            } else {
                                mappedResult.put(fields[i], '');
                            }
                        }
                        else {
                            String valToAssign = '';
                            System.debug('###Else part###-----'+fields[i] + '-----------');
                            if (this.getFieldTypeName(objectType, fields[i]) == 'ADDRESS') {
                               
                                valToAssign = 'Test Address';
                            }
                            else if(this.getFieldTypeName(objectType,fields[i]) == 'DATE')
                            {
                             System.debug('###DATE FIELD'+results.get(fields[i]));
                            
                                     if(results.get(fields[i])!=null)
                                     {
                                     Date d=(Date) results.get(fields[i]);
                                     valToAssign=d.format();
                                     }
                             System.debug('###DATE FIELD valToAssign'+valToAssign);
                                         
                             
                            
                            }  
                             else if(this.getFieldTypeName(objectType,fields[i]) == 'DATETIME')
                            {
                             System.debug('###DATE TIME FIELD'+results.get(fields[i]));
                                     if(results.get(fields[i])!=null)
                                     {
                                     DateTime d=(DateTime) results.get(fields[i]);
                                     valToAssign=d.date().format();      
                                     }                       
                             System.debug('###DATE FIELD valToAssign'+valToAssign);                            
                            }                        
                                                    
                            else
                            {
                                valToAssign = string.valueOf(results.get(fields[i]));
                            }
                            
                            if (valToAssign == null) {
                                valToAssign = '';
                            }
                            mappedResult.put(fields[i], valToAssign);
                        }
                        System.debug('###Results###' + fields);
                    }
                } 
                else {
                    for(integer i=0; i<fields.size(); i++) {
                        mappedResult.put(fields[i], '');
                    }
                }
            }
        }
        catch(Exception e) {
           System.debug('An error occured: ' + e);
        }       
        System.debug('mappedResult'+mappedResult);
        return mappedResult;
    }
    
    public Map<String, String> manageBaseObjectFields(List<String> baseObjFields) {
        System.debug('###manageBaseObjectFields: baseObjeFields:###' + baseObjFields);
        Map<String, String> fieldsWithValue = new Map<String, String>();
        if (baseObjFields.size() > 0) {
            String cond = 'id = \'' + baseObjectId + '\'';
            sObject results = this.buildAndExecuteQuery(baseObjFields, baseObjectName, cond);
            fieldsWithValue = replaceBaseObjectFields(baseObjFields, results);
            System.debug('###manageBaseObjectFields: fieldsWithValue->###' + fieldsWithValue);
        }
        return fieldsWithValue;
    }
    
    public Map<String, String> manageBaseObjFieldsWithCond(List<String> baseObjFieldsWithCond) {
        System.debug('###manageBaseObjFieldsWithCond: baseObjFieldsWithCond:###' + baseObjFieldsWithCond);
        List<String> fList = new List<String>();
        Map<String, String> mappedRes = new Map<String, String>();
        Map<String, String> finalRes = new Map<String, String>();
        String cond;
        String baseField;
        sObject results;
        
        for (Integer i = 0; i < baseObjFieldsWithCond.size(); i++) {
            if (baseObjFieldsWithCond[i].contains(whereIdentifier)) {
                baseField = baseObjFieldsWithCond[i].substringbefore(whereIdentifier);
                fList.add(baseField);
                cond = baseObjFieldsWithCond[i].substringAfter(whereIdentifier);          
                cond = cond + ' and id = \'' + baseObjectId + '\'';
                results = this.buildAndExecuteQuery(fList, baseObjectName, cond);
                mappedRes = this.replaceBaseObjectFields(fList, results);
                finalRes.put(baseObjFieldsWithCond[i], mappedRes.get(baseField));
            }
        }
        return finalRes;
    }
    
    /**
    * get values of parent to child fields      
    * @input List<String> pTOCFields    
    * @output Map<String, String> fieldsWithValue          
    **/
    public Map<String, String> managePToCFields(List<String> pToCFields) {
        System.debug('###managepToCFields: pToCFields:###' + pToCFields + ' Size:' + pToCFields.size());
        Map<String, String> mappedRes = new Map<String, String>();
        sObject result;
        String html;
        String cond;
        for(integer i=0; i < pToCFields.size(); i++) {
            html = '';
            html = buildAndExecutePToCQuery(pToCFields[i], baseObjectName, cond);
            mappedRes.put(pToCFields[i], html);
            System.debug('###parent to child query resulting html ### for element '+i+' : '+html);
        }
        return mappedRes;
    }
    
    /**
    * get values of parent to child fields  with conditions   
    * @input List<String>  pToCFieldsWithCond  
    * @output Map<String, String> fieldsWithValue          
    **/
    public Map<String, String>  managePToCFieldsWithCond(List<String> pToCFieldsWithCond) {
        System.debug('###managepToCFields: pToCFields:###' + pToCFieldsWithCond + ' Size:' + pToCFieldsWithCond.size());
        sObject result;
        String cond;
        String html='';
        Map<String, String> mappedRes = new Map<String, String>();
       
        for(integer i=0; i <pToCFieldsWithCond.size(); i++) {
            if (pToCFieldsWithCond[i].contains(whereIdentifier)) {
                html = '';
                cond  = pToCFieldsWithCond[i].substringAfter(whereIdentifier);
                html= buildAndExecutePToCQuery(pToCFieldsWithCond[i], baseObjectName, cond);
                mappedRes.put(pToCFieldsWithCond[i], html);
                System.debug('###parent to child with condition query result### for element '+i+' : '+result);
            }
        }
        return mappedRes;
   }
   
   /**
    * Mananging direct queries   
    * @input List<String>  directQueries
    * @output Map<String, String> directQueryResults
    **/
    public Map<String, String> manageDirectQueries(List<String> directQueries) {
        Map<String, String> directQueryResults = new Map<String, String>();
        String qFields;
        String labelFields;
        String query;
        String befQuery;
        String htmlTable = '';
        sObject[] qResult;
        List<List<String>> resultsList = new List<List<String>>();
        
        System.debug('inside manageDirectQueries');
        for(integer i=0; i < directQueries.size(); i++) {
            resultsList = new List<List<String>>();
            query = directQueries[i].substringAfter(queryIdentifier);
            // Newly added line below
            query = query.substringBefore(';');
            query = query.trim();
            //befQuery = directQueries[i].substringBefore(queryIdentifier);
            qFields = directQueries[i].substringAfter(fieldsIdentifier);
            qFields = qFields.substringBefore(';');
            // If it contains labels
            if(directQueries[i].contains(labelIdentifier)) {
                labelFields = directQueries[i].substringAfter(labelIdentifier);
                labelFields = labelFields.substringBefore(';');
            }
            
            System.debug('###directquery-->'+query+'###directfields-->'+qFields+'###labelFields -->'+labelFields);
            List<String> directFields=new List<String>();
            if(qFields.contains(comma)) {
                String[] arr = qFields.split('\\,');
                System.debug('qFields arr'+arr);
                if(arr.size() > 0) {
                    for(integer j=0;j<arr.size();j++) {
                        directFields.add(arr[j].trim());         
                    }
                } 
            }
            else {
                directFields.add(qFields.trim());
            }
             System.debug('###directFieldsList#'+directFields);
         
             List<String> labels = new List<String>();
              if (labelFields != null) {
                if(labelFields.contains(comma)) {
                    String[] arr =labelFields.split('\\,');
                    System.debug('labelFields arr'+arr);
                    if(arr.size() > 0) {
                        for(integer j=0;j<arr.size();j++) {
                         labels.add(arr[j].trim());         
                        }
                    } 
                }
                else {
                    labels.add(labelFields.trim());
                }
             }
             System.debug('###Labels List#' + Labels);
             try
             {
                //Replacing baseObjectIdIdentifier Placehoder by its actual value
                if (query.contains(baseObjectIdIdentifier)) {
                    query = query.replace(baseObjectIdIdentifier, '\'' + baseObjectId + '\'');
                }
                
                //Replacing patent templateIdentifier Placehoder by its actual value
                if (query.contains(pTemplateIdentifier)) {
                    query = query.replace(pTemplateIdentifier, '\'' + pTemplateId + '\'');
                }               
                
                System.debug('###Direct final query--->' + query);
                qResult = Database.query(query);
                List<String> record = new List<String>(); 
                if (qResult != null) {
                    for (SObject result :qResult) { 
                        record = new List<String>();
                        Map<String,String> recordValues=new  Map<String,String>();
                        recordValues=replaceBaseObjectFields(directFields,result);              
                        for(integer k = 0;k < directFields.size(); k++) {
                            record.add(recordValues.get(directFields[k]));                                      
                        }
                        System.debug('record'+record);
                        resultsList.add(record);        
                    }
                }
                System.debug('###resultsList'+ resultsList);
                
                //getting Options
                Map<String,String> Options = this.getOptionsFromPlaceHolders(directQueries[i]);
                //Provide Extra Options for HTML Display
                htmlTable = getListAsHtmlTable(resultsList, labels, options);
                directQueryResults.put(directQueries[i],htmlTable);
            } catch (exception e) {
                System.debug('@@@manageDirectQuries: Exception Occured: ' + e);
            }
        }
        System.debug('###manageDirectQuries: directQueryResults: ' + directQueryResults);
        return directQueryResults;
    }
    
    /*
     * Seperate Placeholder options provided as input and assign to a map
    */
    public Map<String,String> getOptionsFromPlaceHolders(String placeHolderCnt) {
        Map<String,String> xTraOptions = new Map<String, String>();
        
        if (placeHolderCnt.contains(optionsIdentifier)) {
            String dOptions;
            dOptions = placeHolderCnt.substringAfter(optionsIdentifier);
            dOptions = dOptions.substringBefore(';');
            
            String[] optsList = new String[]{};
            if(dOptions.contains(comma)) {
                optsList = dOptions.split('\\,');
            } else {
                optsList.add(dOptions);
            }
            System.debug('###getOptionsFromPlaceHolders -> optsList: '+ optsList);
            if (optsList.size() > 0) {
                for(Integer i = 0; i < optsList.size(); i++) {
                    if(optsList[i].contains('=')) {
                        String[] optsKeyVal = optsList[i].split('\\=');
                        if (optsKeyVal.size() > 0) {
                            xTraOptions.put(optsKeyVal[0], optsKeyVal[1]);
                        }
                    }
                }
            }
        }
        System.debug('###getOptionsFromPlaceHolders -> xTraOptions: '+ xTraOptions);
        return xTraOptions;
    }
   
    public String getListAsHtmlTable(List<List<String>> listOfValues, List<String> labels, Map<String, String> options) {
        Dyna_DisplayRecords display = new Dyna_DisplayRecords();
        this.helperHandsonTableData = listOfValues;
        System.debug('#### getListAsHtmlTable() --> helperHandsonTableData' + this.helperHandsonTableData);
        //return display.horizList(listOfValues, labels, null, null);
        Integer numOfPageLayoutCols = 1;
        if (options.size() > 0 && options.containsKey('pageColumns') == true) {
            numOfPageLayoutCols = Integer.valueof(options.get('pageColumns').trim());
        }
        return display.dynaListing(listOfValues, labels, numOfPageLayoutCols);
    }
   
    public Map<String, String> manageSpecialFields(List<String> specialFields) {
        Map<String, String> finalRes = new Map<String, String>();
        String cond;
        for(integer i=0; i < specialFields.size(); i++) {
            if (specialFields[i].contains('@currentDate#')) {
                Date d = date.today();
                //Different date formats: 'dd/MM/YYYY', 'MM/dd/YYYY', 'MM.dd.yyyy'
                String currentDateVal = DateTime.newInstance(d.year(), d.month(), d.day()).format(dateFormat);
                system.debug('### currentDate: ' + currentDateVal);
                finalRes.put(specialFields[i], currentDateVal);
            }
        }
        System.debug('### manageSpecialFields: finalRes -> ' + finalRes);
        return finalRes;
    }
    
    public String replaceHtmlCode(Map<String, String> valMap, String htmlCode) {
       String holderKey;
       for (String key : valMap.keySet()) {
            holderKey = startSeparator + key + endSeparator;
            System.debug('###holderKey'+holderKey);
            htmlCode = htmlCode.replace(holderKey, valMap.get(key));
        }
        return htmlCode;
    }
     public String replaceUrlParams(Map<String, String> valMap, String htmlCode) {
       String holderKey;
       for (String key : valMap.keySet()) {
            holderKey = '@'+key+'#';
            System.debug('###holderKey'+holderKey);
            htmlCode = htmlCode.replace(holderKey, valMap.get(key));
        }
        return htmlCode;
    }
    public Blob getContentsFromResource(String resourceUrl) {
    //'/resource/MyResourceZip/foo.xml'
        PageReference pr = new PageReference(resourceUrl);
        Blob content = pr.getContent();
        return content;
    }
    
    public String findChildObjectPluralLabel(String objectAPIName){
        String childObjectPluralLabel= '';
        try {
             //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();              
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String objectNameInLoop = r.getName();
                if (objectNameInLoop!=null && objectNameInLoop.equals(objectAPIName)){
                    childObjectPluralLabel = r.getLabelPlural();
                    if (r.isCustom()) {
                        childObjectPluralLabel= (childObjectPluralLabel+'__r').replaceAll(' ', '_');
                    }
                    System.debug('###findChildObjectPluralLabel:childObjectPluralLabel###' + childObjectPluralLabel);
                    break;
                }
            }
        } catch(Exception e) {
            System.debug(e);
        }
        return childObjectPluralLabel ;
    }
    
    /**
    returns child objects of the base object
    * @input String baseObjectName
    *
    * @output Set<String> childObjects     
    
    **/    
    public Set<String> getChildren(String baseObjectName) {
        Set<String> uniqueChildren  = new Set<String>();
        try {
        List<String> childObjects=new List<String>{};
        String[] types = new String[]{};
        types.add(baseObjectName);
        Schema.DescribeSobjectResult[] result = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : result) {
           Schema.ChildRelationship[] rels = res.getChildRelationships();       
        
            for (Schema.ChildRelationship cr:rels) 
            {
              childObjects.add(string.valueOf(cr.getChildSObject()));
              system.debug('====child object==='+cr.getChildSObject());
            }
        }
        uniqueChildren  = new Set<String>(childObjects);
        System.debug('childObjects'+childObjects.size());
        System.debug('Unique Children'+uniqueChildren.size());  
                
        }
        catch(Exception e){
            System.debug('getChildren() -> Exception:' + e);                
        }         
        return uniqueChildren;
    }
    
    /**
     *   Returns list of fields and their related information
    **/
    public String getFields(String baseObjectName)
    {
        String jsonString = '';
        try {
            SObjectType accountType = Schema.getGlobalDescribe().get(baseObjectName);
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            Integer count = 0;
            JSONGenerator generator = JSON.createGenerator(true);   
            generator.writestartObject();
            generator.writeFieldName('fields');
            generator.writeStartArray();       
            
            for(Schema.SObjectField sfield : mfields.Values()) {
                generator.writeStartObject();
                schema.describefieldresult dfield = sfield.getDescribe();
                system.debug('#######Field Name' + dfield.getName());
                system.debug('#######Field Type' + dfield.getType().name()); 
                system.debug('#######Relationship Name' + dfield.getRelationshipName());
                system.debug('#######Reference Object' + dfield.getReferenceTo());
                System.debug('#######isNamePointing' + dfield.isNamePointing());
                List<Schema.sObjectType> referenceObjects=new List<Schema.sObjectType>();
                List<String> references =new List<String>();
                if(dfield.getType().name()=='REFERENCE') {
                    referenceObjects=dfield.getReferenceTo();
                    generator.writeStringField('Label', dfield.getName()+ '' + '>');   
                } else {                               
                    generator.writeStringField('Label', dfield.getName());
                }
                generator.writeStringField('Name', dfield.getName());
                generator.writeStringField('Type', dfield.getType().name());
                if(dfield.getRelationshipName()!=null) {
                    generator.writeStringField('Relationship Name',dfield.getRelationshipName());   
                } else {
                    generator.writeStringField('Relationship Name','');     
                }
                generator.writeBooleanField('isNamePointing',dfield.isNamePointing());  
                for (integer i = 0; i<referenceObjects.size(); i++) {
                    references.add(String.valueOf(referenceObjects[i]));
                }
               generator.writeObjectField('References',references);                                                 
               generator.writeEndObject();          
               count++;
            }
            generator.writeEndArray();
            generator.writeEndObject();   
            jsonString = generator.getAsString();
            system.debug('###fields count'+count);
            System.debug('JSON String'+generator.getAsString());
        }
        catch(Exception e) {
            System.debug('getFields() -> Exception' + e);
        }             
        return  jsonString;
    }
    
    //get data type of a field
    public String getFieldTypeName(String sObjectName, String fieldApiName) {
        String fieldTypeName = '';
        System.debug('###getFieldTypeName: sObjectName' + sObjectName + ' fieldApiName--> ' + fieldApiName);
        try {
            fieldTypeName = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getType().name(); 
        } catch(Exception e) {        
            System.debug('### getFieldTypeName Exception :'+e);
        }
        System.debug('### FieldTypeName'+fieldTypeName);
        return fieldTypeName;            
    }   
       
    /* 
    * Get address from address map
    */ 
    Public String getAddress(Map<String,Object> addressMap)
    {
        String addr = '';
        try {
            String city = String.valueOf(addressMap.get('city'));
            String country = String.valueOf(addressMap.get('country'));
            String state = String.valueOf(addressMap.get('state'));
            String street = String.valueOf(addressMap.get('Street'));
            String postalCode = String.valueOf(addressMap.get('PostalCode'));
            String stateCode = String.valueOf(addressMap.get('StateCode'));
            String countryCode = String.valueOf(addressMap.get('countryCode'));        
            addr = street + ' '+state +' '+ city + '</br>' + postalCode +' '+ country;
        }
        catch(Exception e) {        
            System.debug('### getAddress Exception :'+e);    
        }
    
      /*  if(addr.contains('null')) {
            addr.replace('null','');
        }*/
        System.debug('### address string'+addr);
        return addr;  
    }
    
    public Map<String, String> manageWhatTypeFields(List<String> whatFields) {
        Map<String, String> finalResult = new Map<String, String>();
        List<String> whatConvertedToActualObjFields = new List<String>();
        if (whatFields.size() <= 0) {
            return finalResult;
        }
        String q = 'Select WhatId, Id from ' + baseObjectName + ' where id = \'' + baseObjectId + '\'' ;
        System.debug('###manageWhatTypeFields --> BaseObj Query: ' + q);
        Sobject qResult = Database.query(q);
        String sWhatId = String.valueOf(qResult.get('WhatId'));
        String actualObj = this.findObjectNameById(sWhatId);
        String condition = 'id=\''+ sWhatId + '\'';
        System.debug('###manageWhatTypeFields --> condition: ' + condition);
        
        for(integer i=0; i < whatFields.size(); i++) {
            if (whatFields[i].containsIgnoreCase(spclWhatDotIdentifier)) {
                //replacing what. in placeholder as ''
                whatConvertedToActualObjFields.add(whatFields[i].replace(spclWhatDotIdentifier, ''));
            }
        }
        System.debug('###manageWhatTypeFields --> whatConvertedToActualObjFields: ' + whatConvertedToActualObjFields);
        
        //get results as sObjects of actual object applied in query
        sObject actualObjResult = this.buildAndExecuteQuery(whatConvertedToActualObjFields, actualObj, condition);
        System.debug('###manageWhatTypeFields --> actualObjResult: ' + actualObjResult);
        
        //Extract values for requested fields and give result as map
        Map<String, String> valuesReplaced = this.replaceBaseObjectFields(whatConvertedToActualObjFields, actualObjResult);
        System.debug('###manageWhatTypeFields --> valuesReplaced: ' + valuesReplaced);
        
        Integer j = 0;
        for (String replacedMapKey : valuesReplaced.keySet()) {
            finalResult.put(whatFields[j], valuesReplaced.get(replacedMapKey));
            j++;
        }

        System.debug('###manageSpecialFields --> finalResult: ' + finalResult);
        return finalResult;
    }
}
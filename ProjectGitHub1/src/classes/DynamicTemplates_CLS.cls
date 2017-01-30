public class DynamicTemplates_CLS
{
    public string selected{get; set;}
    public Boolean isFlag{get; set;}
    public string selectedTemplateId {get; set;}
    public String param{get; set;} //param to pass value in URL
    private integer counter = 0;  //keeps track of the offset
    private integer list_size = 5; //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list
    public String baseObject{get; set;}
    public String baseObjectId{get; set;}
    public String toolNamespace {get; set;}
    
    //set the total size in the constructor
    public DynamicTemplates_CLS() {
        baseObjectId = ApexPages.currentPage().getParameters().get('param');
        Dyna_TemplateHelper dHelper = new Dyna_TemplateHelper();
        baseObject = dHelper.findObjectNameById(baseObjectId);
        System.debug('objectName: ' + baseObject + ', ObjectId: '+baseObjectId);
        
        total_size = [select count() from dynamictemplate__c where relatedobject__c =:baseObject];
        toolNamespace = getNamespacePrefix();
    }
    
    public static String getNamespacePrefix() {
        String namespace = '';
        try {
            ApexClass ac = [SELECT NameSpacePrefix FROM ApexClass WHERE Name = 'DynamicTemplates_CLS'];
            if(null != ac.NameSpacePrefix) {
                namespace = ac.NameSpacePrefix + '__';
            }
        } catch (QueryException ex) {
            System.debug('Dyna Tool: Problem Fetching Namespace, Exception: ' + ex);
        }
        return namespace;
    }
  
    public dynamictemplate__c[] gettemps() 
    {
        dynamictemplate__c[] temps;
        try {
            temps = [select name, HTMLHeader__c, Description__c, order__c, Version__c, relatedobject__c, CreatedDate 
                     from dynamictemplate__c  where relatedobject__c =:baseObject order by CreatedDate limit :list_size 
                     offset :counter];
                     System.debug('\n\n\n@@@@@@@@@@@@@@@@@@@@@@Get Templates :'+ temps );
        } 
        catch (QueryException e) {
            ApexPages.addMessages(e);
        }
        return temps;
   }
 
    public PageReference getSelected()
    {
        System.debug('Entered Template selection block===>');
        selectedTemplateId = ApexPages.currentPage().getParameters().get('tmpId');      
        return null;
    } 
  
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        return null;
    }
   
    public PageReference Beginning() { //user clicked beginning
      counter = 0;
      return null;
    }
    
    public PageReference Next() { //user clicked next button
      counter += list_size;
      return null;
    }
    
    public PageReference last() { //user clicked end
      counter = total_size - math.mod(total_size, list_size);
      return null;
    }
    
    public Boolean getDisablePrevious() { 
      //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter + list_size < total_size) return false; else return true;
    }
    
    public Integer getTotal_size() {
      return total_size;
    }
    
    public Integer getPageNumber() {
      return counter/list_size + 1;
    }
    
    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }         
}
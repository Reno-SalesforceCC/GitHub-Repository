Public Class MyClass{
    @TestVisible Account aL = new Account();
    Public Account MyClass1(Account a){
        
        aL = [Select id,name from Account where name =: a.name Limit 1];
      System.debug('Generate WSDL for Class'+a);
        return aL;
    }
}
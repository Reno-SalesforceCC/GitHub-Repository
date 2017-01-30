trigger Update_Contact on Account (after Insert, after update) {
    If(Trigger.isUpdate && Trigger.isAfter){
        testCls.myMethod();
    }
    System.debug('-----------------');
    List<Contact> c1_l = new List<Contact>();
    If(Trigger.isAfter && Trigger.isInsert){
    Set<Id> aID = new Set<Id>();
     
    for(Account a : Trigger.new){
       aID.add(a.Id);
    }
    List<Contact> c_L = [Select AccountId, Name from Contact where AccountId IN: aID];
    for(Contact c : c_L){
      c.description= c.name + '001';
      c1_l.add(c);
    }
    If(c1_l.size() > 0 && c1_l != NULL){
    system.debug('-----------------'+c1_l.size());
    try{
        Update c1_l;
    }catch(Exception e){
    }
      
    }
    }
}
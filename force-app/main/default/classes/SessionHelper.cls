public without sharing class SessionHelper {

    public Boolean passed;
    public String log;
   
    public SessionHelper(Boolean passed, String log){
        this.log = log;
        this.passed = passed;
    }
}
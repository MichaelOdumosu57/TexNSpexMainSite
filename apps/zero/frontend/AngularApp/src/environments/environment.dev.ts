import { HttpParams } from '@angular/common/http';
import { SITE_OFFLINE_ENUM } from '@core/site-offline/site-offline.component';
import { WMLEndpoint } from '@windmillcode/wml-components-base';

export let environment = {
  production: false
}


export let traverseClassAndRemoveAutomationForProduction = (obj,stack=[])=>{
  Object.entries(obj).forEach(entry=>{
    let [key,value] = entry
    if(value instanceof Object){
      stack.push(obj[key])
      traverseClassAndRemoveAutomationForProduction(value,stack)
      stack = []
    }
    else{
      if(key ==="automate"){
        stack[stack.length-1].automate = false
      }
    }
  })
}

export class DevEnv {

  type:"dev" | "preview" | "prod" = "dev"
  endpointMsgCodes = {
    'success':'OK',
    'error':'ERROR',
  }

  errorCodes = {
  }

  app:any={
    backendHealthCheck:() =>this.backendDomain0 + "/healthz/",
    siteOffline:SITE_OFFLINE_ENUM.FALSE
  }


  // backendDomain0 ="https://example.com:5000"
  backendDomain0 =" https://127.0.0.1:5000"
  frontendDomain0 ="https://example.com:4200"
  classPrefix= {
    app:"App"
  }

  nav = {
    urls:{
      home:"/",
      homeAlt:"/home",
      sample:"/sample",
      profile:"/profile",
      profileTypeQuestionaire:"/product-survey",
      initialURL:"",
      siteOffline:"/site-offline"
    },
    spotifyLoginEndpoint:() => this.backendDomain0 + "/spotify/login"
  }

  candidacyInfoForm = {
    mainForm:{
      companyFormControlName:"company",
      jobDescFormControlName:"jobDesc",
      resumeFormControlName:"resume"
    }
  }



  questionaireOneMain = {
    mainForm:{
      cognitoUserIdFormControlName:"cognitoUserId"
    }
  }

  joinWaitlistForm = {
    mainForm:{
      nameFormControlName:"name",
      emailFormControlName:"email",
      phoneFormControlName:"phone",
    }
  }

  resumeService = {
    submitFormToAnalyzeResume:new WMLEndpoint({
      url:()=> this.backendDomain0 + "/resume/analyze"
    })
  }

  userService = {
    getProfileTypeQuestions:new WMLEndpoint({
      url:()=> this.backendDomain0 + "/user_profile/get_type_questions"
    }),
    saveProfileTypeAnswers:new WMLEndpoint({
      url:()=> this.backendDomain0 + "/user_profile/save_type_answers"
    })
  }

  intakeService = {
    joinWaitList:new WMLEndpoint({
      url:()=> this.backendDomain0 + "/intake/join_waitlist"
    })
  }

  constructor(){
    // traverseClassAndRemoveAutomationForProduction(this)
  }
}

export let ENV =   new DevEnv()



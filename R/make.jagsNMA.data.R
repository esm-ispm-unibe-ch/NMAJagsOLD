

make.jagsNMA.data=function(studyid,r,n,y,sd,t,type="cont", data, reference=1){
  #this function takes a dataset in long NMA format and produces a list suitable for JAGS or WinBUGS
  #id is the study id with repetitions for arms
  #r events
  #n numbers randomised
  #y means
  #sd the standard deviations
  #type, character for "dich"or "cont"
  # data the dataset to use
  
  ##---- Get data and re-name when needed ----#
 
   data$idd=eval(substitute(id), data)
  data$tt=eval(substitute(t), data)
  n=data$n=eval(substitute(n), data)
  idd=data$idd
  idd=as.numeric(as.factor(idd))#make sure study ids are consequetively numbered
  tt=data$tt
  ns=length(unique(idd))
  nt=length(unique(tt))
  na=table(idd)
  r=rep(1:ns,table(idd))#renames study id when it is not consequetively ordered
  t=as.numeric(as.factor(tt))#renames treatments
  if(!identical(t,tt)){
    print("Note: the treatments have been renamed as follows")
    out<-cbind.data.frame("old names"=sort(unique(tt)),"new names"=sort(unique(t)))
    refer=sort(unique(t))[sort(unique(tt))==reference]
  print(out)}
 
  maxnrofarms=max(table(idd))
   nofarms<-length(idd)
   armsenumerate=unlist(sapply(na,seq))
  tmat<-matrix(999,nrow=ns,ncol=maxnrofarms)
  for(i in 1:nofarms){
    tmat[idd[i],armsenumerate[i]]=t[i]
  }
  # t matrix only to return in the end
  tmat2=t(apply(tmat,1,sort))
  tmat2[tmat2==999]<-NA
  #t matrix to take forward and make the data matrices
  tmat[tmat==999]<-NA
 
  
  nmat<-matrix(-99,nrow=ns,ncol=nt)
  for(i in 1:nofarms){
  nmat[idd[i],t[i]]<-n[i]
  }
  nmat[nmat==-99]<-NA
  
  if(type=="cont"){
    y=data$y=eval(substitute(y), data)
    sd=data$sd=eval(substitute(sd), data)
    prec=1/(sd*sd)
    ymat<-matrix(9999,nrow=ns,ncol=nt)
    precmat<-matrix(-99,nrow=ns,ncol=nt)
    for(i in 1:  nofarms){
      ymat[idd[i],t[i]]=y[i]
      precmat[idd[i],t[i]]=prec[i]
    }
    ymat[ymat==9999]<-NA
    precmat[precmat==-99]<-NA
    
    #calculate the study-specific pooled SD
    nominator=sqrt(tapply(n*sd*sd,idd, sum))
    denominator=sqrt(tapply(n,idd,sum)-na)
    pooled.sd=nominator/denominator
    
    return(list(ns=ns,nt=nt,na=na,t=tmat2,y=ymat,prec=precmat,pooled.sd=pooled.sd,ref=reference))
    }
  
  if(type=="binary"){
    r=data$r=eval(substitute(r), data)
    rmat<-matrix(-99,nrow=ns,ncol=nt)
    for(i in 1:  nofarms){
      rmat[idd[i],t[i]]=r[i]
    }
    rmat[rmat==-99]<-NA
    return(list(ns=ns,nt=nt,na=na,t=tmat2,r=rmat,n=nmat,ref=refer))
  }
 
#END 
}
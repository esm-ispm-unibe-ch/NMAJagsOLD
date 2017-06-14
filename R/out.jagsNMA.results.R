out.jagsNMA.results=function(JAGSobject,parameter=parameter,forestplot=T){
  resultstable=JAGSobject$BUGSoutput$summary
  allvariablenames=rownames(resultstable)
  rowsmatching=substr(allvariablenames,1,nchar(parameter))
  rowstokeep=startsWith(rowsmatching,parameter)

  resultstabletokeep=resultstable[rowstokeep,c(1,3,7,2)]
  
  library(stringr)
  tosplit=unlist(strsplit(rownames(resultstabletokeep),","))
  tosplit2 <- as.numeric(str_extract(tosplit, "[0-9]+"))
  nroftreatments=max(tosplit2)
  location=matrix(tosplit2,ncol=2,byrow=T)
  meanmat=CImat=sdmat=matrix(NA,nrow=nroftreatments,ncol=nroftreatments)

for(i in 1:nrow(location)){
  meanmat[location[i,1],location[i,2]]=resultstabletokeep[i,1]
  sdmat[location[i,1],location[i,2]]=resultstabletokeep[i,4]
  CImat[location[i,1],location[i,2]]=resultstabletokeep[i,3]#high CI
  CImat[location[i,2],location[i,1]]=resultstabletokeep[i,2]#low CI
  
}
  if(forestplot){
    library(metafor)
    slab1=rep(1:(nroftreatments-1),(nroftreatments-1):1)
    a=t(sapply(1:nroftreatments,rep,nroftreatments))
    slab2=a[lower.tri(a,F)]
    slab=paste(slab1,"vs",slab2,sep="")
  forest(x=meanmat[upper.tri(meanmat)], ci.lb=CImat[lower.tri(CImat)],ci.ub=CImat[upper.tri(CImat)], slab=slab,xlab="Network meta-analysis results")
    }

list(Means=meanmat,CI=CImat)
}
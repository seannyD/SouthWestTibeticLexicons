library(ape)


#(Old Tibetan,((Alike,Xiahe),(Batang,(Lhasa,(((Gyalsumdo,Nubri),Tsum,(Yolmo,Kagate)),Lowa,(Sherpa,Jirel)))));

#glottologTree = read.tree(text="(((Gyalsumdo,Nubri),Tsum,(Yolmo,Kagate)),Lowa,(Sherpa,Jirel));")
glottologTree = read.tree(text="(Old Tibetan:1,((Alike,Xiahe),(Batang,(Lhasa,(((Gyalsumdo,Nubri),Tsum,(Yolmo,Kagate)),Lowa,(Sherpa,Jirel))))));")
glottologTree = compute.brlen(glottologTree)
glottologTree$edge.length[1] = 0.3
glottologTree = ladderize(glottologTree)
plot(glottologTree,cex=1,main="Glottolog tree",tip.color=c(1,1,1,1,1,2,2,2,2,2,2,2,2))


tree5 = read.tree(text="(((Gyalsumdo,Nubri),Tsum),Lowa,Jirel);")

plot(tree5,cex=2)

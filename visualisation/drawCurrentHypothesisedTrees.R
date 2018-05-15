library(ape)


glottologTree = read.tree(text="(((Gyalsumdo,Nubri),Tsum,(Yolmo,Kagate)),Lowa,(Sherpa,Jirel));")
glottologTree = ladderize(glottologTree)
plot(glottologTree,cex=2)


tree5 = read.tree(text="(((Gyalsumdo,Nubri),Tsum),Lowa,Jirel);")

plot(tree5,cex=2)

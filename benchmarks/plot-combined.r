#!/usr/lib/R/bin/Rscript

library(methods)
library(ggplot2)

args  = commandArgs(TRUE)
rack  = read.table(file=args[1], sep=",", header=T)
rails = read.table(file=args[2], sep=",", header=T)

x  = rack$concurrent
y1 = rack$throughput
y2 = rails$throughput

df = data.frame(x, y1, y2)

g = ggplot(df, aes(x, y1, y2)) +
	scale_x_log10(breaks=c(10, 50, 100, 500, 1000, 5000, 10000)) +
	scale_y_continuous(breaks=round(seq(5000, 12000, by=1000), 1)) +
    geom_line(aes(y=y1)) + geom_point(aes(y=y1)) +
    geom_line(aes(y=y2)) + geom_point(aes(y=y2)) +
    ylab("Requests per second") +
	xlab("Concurrent clients (log.)") +
	theme_bw()

path = paste(args[1], "combined", "pdf", sep=".")
print(path)
ggsave(g, file=path)

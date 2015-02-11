#!/usr/lib/R/bin/Rscript

library(methods)
library(ggplot2)

args   = commandArgs(TRUE)
values = read.table(file=args[1], sep=",", header=T)

x  = values$concurrent
y1 = values$throughput
y2 = values$loss

df = data.frame(x, y1)

g = ggplot(df, aes(x, y1)) +
	scale_x_log10() +
    geom_line(aes(y=y1)) +
    ylab("Requests per second") +
	xlab("Concurrent clients (log.)") +
	theme(panel.background = element_rect(fill='white', colour='black'))

path = paste(args[1], "pdf", sep=".")
print(path)
ggsave(g, file=path)

#!/usr/lib/R/bin/Rscript

library(methods)
library(ggplot2)
library(reshape2)

args  = commandArgs(T)
rack  = read.table(file=args[1], sep=',', header=T)
rails = read.table(file=args[2], sep=',', header=T)

Concurrent = rack$concurrent
Rack = rack$throughput
Rails = rails$throughput

df = data.frame(Concurrent, Rack, Rails)
df.long = melt(df, id.vars='Concurrent')

sd = c(rack$sd, rails$sd)
df.long = cbind(df.long, sd)

g = ggplot(df.long, aes(Concurrent, value, shape=variable)) +
	scale_x_log10(breaks=c(10, 50, 100, 500, 1000, 5000, 10000)) +
	scale_y_continuous(breaks=round(seq(1000, 15000, by=1000), 1)) +
    scale_shape(name='Framework') +
    ylab('Requests per second') +
	xlab('Concurrent clients (log.)') +
	geom_line() +
	geom_point() +
 	geom_errorbar(aes(ymin=value-sd, ymax=value+sd)) +
	theme_bw()

path = paste(args[1], 'frameworks', 'pdf', sep='.')
print(path)
ggsave(g, file=path)

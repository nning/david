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

g = ggplot(df.long, aes(Concurrent, value, shape=variable)) +
	scale_x_log10(breaks=c(10, 50, 100, 500, 1000, 5000, 10000)) +
	scale_y_continuous(breaks=round(seq(5000, 12000, by=1000), 1)) +
    scale_shape(name='Framework') +
    ylab('Requests per second') +
	xlab('Concurrent clients (log.)') +
	geom_line() +
	geom_point() +
	theme_bw()

path = paste(args[1], 'rack-vs-rails', 'pdf', sep='.')
print(path)
ggsave(g, file=path)

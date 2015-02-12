#!/usr/lib/R/bin/Rscript

library(methods)
library(ggplot2)
library(reshape2)

args = commandArgs(T)

mri22_data   = read.table(file=args[1], sep=',', header=T)
mri23_data   = read.table(file=args[2], sep=',', header=T)
jruby17_data = read.table(file=args[3], sep=',', header=T)
jruby9_data  = read.table(file=args[4], sep=',', header=T)
rbx25_data   = read.table(file=args[5], sep=',', header=T)

x       = mri22_data$concurrent
mri22   = mri22_data$loss
mri23   = mri23_data$loss
jruby17 = jruby17_data$loss
jruby9  = jruby9_data$loss
rbx25   = rbx25_data$loss

df = data.frame(x, mri22, mri23, jruby17, jruby9, rbx25)
df.long = melt(df, id.vars='x')

g = ggplot(df.long, aes(x, value, shape=variable)) +
	scale_x_log10(breaks=c(10, 50, 100, 500, 1000, 5000, 10000)) +
    scale_shape(name='Ruby VM') +
    ylab('Percentage of lost messages') +
	xlab('Concurrent clients (log.)') +
	geom_line() +
	geom_point() +
	theme_bw()

path = paste(args[1], 'loss', 'pdf', sep='.')
print(path)
ggsave(g, file=path)

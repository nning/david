#!/usr/lib/R/bin/Rscript

library(methods)
library(ggplot2)
library(reshape2)

args = commandArgs(T)

mri22_data   = read.table(file=args[1], sep=',', header=T)
mri23_data   = read.table(file=args[2], sep=',', header=T)
jruby17_data = read.table(file=args[3], sep=',', header=T)
jruby9_data  = read.table(file=args[4], sep=',', header=T)

x       = mri22_data$concurrent
mri22   = mri22_data$throughput
mri23   = mri23_data$throughput
jruby17 = jruby17_data$throughput
jruby9  = jruby9_data$throughput

df = data.frame(x, mri22, mri23, jruby17, jruby9)
df.long = melt(df, id.vars='x')

sd = c(mri22_data$sd, mri23_data$sd, jruby17_data$sd, jruby9_data$sd)
df.long = cbind(df.long, sd)

g = ggplot(df.long, aes(x, value, shape=variable)) +
	scale_x_log10(breaks=c(10, 50, 100, 500, 1000, 5000, 10000)) +
	scale_y_continuous(breaks=round(seq(1000, 15000, by=1000), 1)) +
    scale_shape(name='Ruby VM') +
    ylab('Requests per second') +
	xlab('Concurrent clients (log.)') +
	geom_line() +
	geom_point() +
 	geom_errorbar(aes(ymin=value-sd, ymax=value+sd)) +
	theme_bw()

path = paste(args[1], 'vms', 'pdf', sep='.')
print(path)
ggsave(g, file=path)

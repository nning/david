#!/bin/sh

[ ! -d coapbench ] && {
	mkdir -p coapbench
	cd coapbench

	git clone https://github.com/eclipse/californium.git
	cd californium
	mvn clean install
	cd -

	git clone https://github.com/eclipse/californium.tools.git
	cd californium.tools
	mvn clean install
	cd -

	cd ..
}

java -jar coapbench/californium.tools/run/cf-coapbench-*.jar $@

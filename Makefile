.PRECIOUS: %/streetGraph.obj
CURL:=curl -\# --create-dirs

download: otp.jar

georgia/osm.pbf:
	${CURL} https://download.geofabrik.de/north-america/us/georgia-latest.osm.pbf -o $@

atlanta/osm.pbf: georgia/osm.pbf
	osmium extract georgia/osm.pbf --polygon atlanta/atlanta.geojson -o $@

atlanta/gtfs.zip:
	${CURL} https://itsmarta.com/google_transit_feed/google_transit.zip -o $@

build-%: otp.jar %/osm.pbf %/gtfs.zip
	java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044 -Xmx12G -jar otp.jar --build $*

run-%: otp.jar
	java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044 -jar otp.jar --server --basePath ./ --router $* --insecure

clean-all:
	find . -name osm.pbf -printf '%p\n' -exec rm {} \;
	find . -name gtfs.zip -printf '%p\n' -exec rm {} \;
	find . -name Graph.obj -printf '%p\n' -exec rm {} \;
	rm -f otp.jar

clean-%:
	find $* -name osm.pbf -printf '%p\n' -exec rm {} \;
	find $* -name gtfs.zip -printf '%p\n' -exec rm {} \;
	find $* -name Graph.obj -printf '%p\n' -exec rm {} \;


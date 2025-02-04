.PRECIOUS: %/streetGraph.obj
CURL:=curl -L -\# --create-dirs

download: otp.jar

massachusetts/osm.pbf:
	${CURL} https://download.geofabrik.de/north-america/us/massachusetts-latest.osm.pbf -o $@

boston/osm.pbf: massachusetts/osm.pbf
	${CURL} https://download.geofabrik.de/north-america/us/massachusetts-latest.osm.pbf -o $@

boston/gtfs.zip:
	${CURL} https://cdn.mbta.com/MBTA_GTFS.zip -o $@

new-york/osm.pbf:
	${CURL} https://download.geofabrik.de/north-america/us/new-york-latest.osm.pbf -o $@

rochester/osm.pbf: new-york/osm.pbf
	osmium extract new-york/osm.pbf --polygon rochester/rochester.geojson -o $@

rochester/gtfs.zip:
	echo "none"

georgia/osm.pbf:
	${CURL} https://download.geofabrik.de/north-america/us/georgia-latest.osm.pbf -o $@

atlanta-tiny/osm.pbf: georgia/osm.pbf
	osmium extract georgia/osm.pbf --polygon atlanta-tiny/atlanta.geojson -o $@

atlanta-tiny/osm-tiny.pbf: georgia/osm.pbf
	osmium extract georgia/osm.pbf --polygon atlanta-tiny/central-atlanta-blue-line.geojson -o $@

atlanta-tiny/osm-tiny-stripped.pbf: atlanta-tiny/osm-tiny.pbf
	osmium tags-filter atlanta/osm-tiny.pbf w/highway w/public_transport=platform w/railway=platform w/park_ride=yes r/type=restriction r/type=route -o $@ -f pbf,add_metadata=true

atlanta-tiny/osm-tiny-stripped-patched.pbf: atlanta-tiny/osm-tiny-stripped.pbf
	osmium apply-changes --output=$@ atlanta/osm-tiny-stripped.pbf atlanta/patch.osc

atlanta-tiny/gtfs.zip:
	${CURL} https://leonard.io/ibi/marta.blue-line-accessible.gtfs.zip -o $@

atlanta/osm.pbf: georgia/osm.pbf
	osmium extract georgia/osm.pbf --polygon atlanta/atlanta.geojson -o $@

atlanta/gtfs.zip: atlanta/osm.pbf
	${CURL} https://itsmarta.com/google_transit_feed/google_transit.zip -o $@

canton/osm.pbf: georgia/osm.pbf
	osmium extract georgia/osm.pbf --polygon canton/canton.geojson -o $@

canton/gtfs.zip:
	${CURL} https://leonard.io/ibi/cats-2.gtfs.zip -o $@

build-%: otp.jar %/osm.pbf %/gtfs.zip
	java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044 -jar otp.jar --build $*

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


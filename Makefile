ns_3_allinone_project="ns-allinone-3.26"
ns_3_docker_image="hamelik/ns3.26libdependencies:first"
ns_3_docker_container="Hello-NS-3.26"

target:
	./build-script.sh

clean:
	rm -r ${ns_3_allinone_project}

ns-3-container-run:
	docker run -it \
		-v `pwd`/${ns_3_allinone_project}/:/usr/local/${ns_3_allinone_project}/ \
		--name ${ns_3_docker_container} ${ns_3_docker_image}

ns-3-container-attach:
	docker attach ${ns_3_docker_container}

ns-3-container-kill:
	docker kill ${ns_3_docker_container}

ns-3-container-rm:
	docker rm ${ns_3_docker_container}


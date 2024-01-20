include .env

all: prepare start connect pin

.PHONY: prepare
prepare:
	mkdir -p $(CURDIR)$(ipfs_staging)
	mkdir -p $(CURDIR)$(ipfs_data)
	docker pull ipfs/kubo:latest

.PHONY: start
start:
	docker run -d --name ipfs -v $(CURDIR)$(ipfs_staging):/export -v $(CURDIR)$(ipfs_data):/data/ipfs -p 4001:4001 -p 4001:4001/udp -p 127.0.0.1:8080:8080 -p 127.0.0.1:5001:5001 ipfs/kubo:latest

.PHONY: connect
connect:
	docker exec ipfs /bin/sh -c "while [ ! -e /data/ipfs/api ]; do echo 'Waiting for IPFS to start'; sleep 1; done"
	docker exec ipfs ipfs swarm connect $(ipfs_peer)

.PHONY: pin
pin:
	docker exec ipfs ipfs pin add --progress --recursive $(ipfs_cid)

.PHONY: kill
kill:
	docker run --rm -v $(CURDIR)$(ipfs_staging):/export -v $(CURDIR)$(ipfs_data):/data/ipfs ipfs/kubo:latest shutdown || true
	docker kill ipfs || true
	docker rm ipfs || true

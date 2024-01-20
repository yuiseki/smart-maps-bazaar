include .env

all: prepare start connect pin

.PHONY: prepare
prepare:
	mkdir -p $(CURDIR)$(ipfs_staging)
	mkdir -p $(CURDIR)$(ipfs_data)
	docker pull ipfs/kubo:latest

.PHONY: start
start:
	docker run -d --name ipfs \
		-v $(CURDIR)$(ipfs_staging):/export \
		-v $(CURDIR)$(ipfs_data):/data/ipfs \
		-p 0.0.0.0:4001:4001 \
		-p 0.0.0.0:4001:4001/udp \
		-p 0.0.0.0:8080:8080 \
		-p 0.0.0.0:3000:3000 \
		-p 0.0.0.0:5001:5001 \
		ipfs/kubo:latest daemon
	docker exec ipfs /bin/sh -c "while [ ! -e /data/ipfs/api ]; do echo 'Waiting for IPFS to start'; sleep 1; done"

.PHONY: connect
connect:
	docker exec ipfs /bin/sh -c "while [ ! -e /data/ipfs/api ]; do echo 'Waiting for IPFS to start'; sleep 1; done"
	docker exec ipfs ipfs swarm connect $(ipfs_peer)

.PHONY: pin
pin:
	docker exec ipfs ipfs pin add --progress --recursive $(ipfs_cid)

.PHONY: kill
kill:
	docker kill ipfs || true
	docker rm ipfs || true
	docker run --rm -v $(CURDIR)$(ipfs_staging):/export -v $(CURDIR)$(ipfs_data):/data/ipfs ipfs/kubo:latest shutdown || true

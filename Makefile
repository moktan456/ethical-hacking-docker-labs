.PHONY: build-base \
        run-week1 run-week3 run-week4 run-week5 run-week6 run-week7 run-week8 run-week9 run-week10 \
        run-week4-kali run-week5-kali run-week6-kali run-week7-kali run-week8-kali run-week9-kali run-week10-kali \
        run-week2 run-week11 run-week12 \
        stop-all clean-all down-all build-all

# ── Build the shared Kali attacker image (run once before any lab) ──────────
build-base:
	docker build -f base.Dockerfile -t ethical-base .

# ── Standard mode: all-Docker (attacker container + targets) ────────────────
run-week1:
	cd labs/week1 && docker compose up -d

run-week2:
	@echo "Week 2: Ethical discussions — no Docker needed."
	@cat labs/week2/README.md 2>/dev/null || true

run-week3:
	cd labs/week3 && docker compose up -d

run-week4:
	cd labs/week4 && docker compose up -d

run-week5:
	cd labs/week5 && docker compose up -d

run-week6:
	cd labs/week6 && docker compose up -d

run-week7:
	cd labs/week7 && docker compose up -d

run-week8:
	cd labs/week8 && docker compose up -d

run-week9:
	cd labs/week9 && docker compose up -d

run-week10:
	cd labs/week10 && docker compose up -d

run-week11:
	@echo "Week 11: Physical access controls — no Docker needed."
	@cat labs/week11/README.md 2>/dev/null || true

run-week12:
	@echo "Week 12: Social engineering — no Docker needed."
	@cat labs/week12/README.md 2>/dev/null || true

# ── Kali VM mode: targets only, ports exposed to host ───────────────────────
# Use these if you prefer to attack from your own Kali VM instead of the
# built-in attacker container.  Find your host IP from Kali with:
#   ip route   →  look for the default gateway, then ping it to confirm
# Targets will be reachable at HOST_IP:<exposed-port> (see each compose file).

run-week4-kali:
	cd labs/week4 && docker compose -f docker-compose.kali.yaml up -d

run-week5-kali:
	cd labs/week5 && docker compose -f docker-compose.kali.yaml up -d

run-week6-kali:
	cd labs/week6 && docker compose -f docker-compose.kali.yaml up -d

run-week7-kali:
	cd labs/week7 && docker compose -f docker-compose.kali.yaml up -d

run-week8-kali:
	cd labs/week8 && docker compose -f docker-compose.kali.yaml up -d

run-week9-kali:
	cd labs/week9 && docker compose -f docker-compose.kali.yaml up -d

run-week10-kali:
	cd labs/week10 && docker compose -f docker-compose.kali.yaml up -d

# ── Teardown ─────────────────────────────────────────────────────────────────
stop-all:
	for week in 1 3 4 5 6 7 8 9 10; do \
		(cd labs/week$$week && docker compose down 2>/dev/null || true); \
		(cd labs/week$$week && docker compose -f docker-compose.kali.yaml down 2>/dev/null || true); \
	done

clean-all:
	docker system prune -f

down-all: stop-all clean-all

build-all: build-base

.PHONY: build-base run-week1 run-week2 run-week3 run-week4 run-week5 run-week6 run-week7 run-week8 run-week9 run-week10 run-week11 run-week12 stop-all clean-all down-all build-all

# Build the shared base image
build-base:
	docker build -f base.Dockerfile -t ethical-base .

# Run specific week
run-week1:
	cd labs/week1 && docker compose up -d

run-week2:
	@echo "Week 2: Ethical discussions - no Docker needed. Review README."
	@cat labs/week2/README.md 2>/dev/null || echo "Create README for Week 2 ethics."

run-week3:
	cd labs/week3 && docker compose up -d

run-week4:
	@test -f labs/week4/docker-compose.yaml -o -f labs/week4/docker-compose.yml && (cd labs/week4 && docker compose up -d) || echo "Week 4 lab not yet built. See labs/week4/ (currently empty)."

run-week5:
	@test -f labs/week5/docker-compose.yaml -o -f labs/week5/docker-compose.yml && (cd labs/week5 && docker compose up -d) || echo "Week 5 lab not yet built. See labs/week5/ (currently empty)."

run-week6:
	cd labs/week6 && docker compose up -d

run-week7:
	cd labs/week7 && docker compose up -d

run-week8:
	cd labs/week8 && docker compose up -d

run-week9:
	@test -f labs/week9/docker-compose.yaml -o -f labs/week9/docker-compose.yml && (cd labs/week9 && docker compose up -d) || echo "Week 9 lab not yet built. See labs/week9/ (currently empty)."

run-week10:
	@test -f labs/week10/docker-compose.yaml -o -f labs/week10/docker-compose.yml && (cd labs/week10 && docker compose up -d) || echo "Week 10 lab not yet built. See labs/week10/ (currently empty)."

run-week11:
	@echo "Week 11: Physical access controls - no Docker needed. Review README."
	@cat labs/week11/README.md 2>/dev/null || echo "Create README for Week 11 physical security."

run-week12:
	@echo "Week 12: Social engineering - no Docker needed. Review README."
	@cat labs/week12/README.md 2>/dev/null || echo "Create README for Week 12 social engineering."

# Build all weeks (if any have Dockerfiles)
build-all:
	$(MAKE) build-base
	for week in 1 3 6 7 8; do \
		if [ -f "labs/week$$week/Dockerfile" ]; then \
			(cd labs/week$$week && docker compose build); \
		fi; \
	done

# Stop all weeks (only the ones that actually exist)
stop-all:
	for week in 1 3 6 7 8; do \
		(cd labs/week$$week && docker compose down 2>/dev/null || true); \
	done

# Clean unused images
clean-all:
	docker system prune -f

# Down all
down-all: stop-all clean-all

# ===========================================================================
# Makefile — Projet Inception (Docker Compose) avec HARD RESET
# Toutes les commandes utiles (lancement, clean, reset, logs) et
# commentaires explicatifs pour comprendre chaque étape.
# ===========================================================================

# -------------------------
# Variables globales du projet
# -------------------------
NAME = inception                        # Préfixe des images/containers
COMPOSE_FILE = srcs/docker-compose.yml  # Chemin du fichier docker-compose
DCOMPOSE = docker compose -f $(COMPOSE_FILE)  # Commande Docker Compose explicite

# -------------------------
# Commande principale — build & up (par défaut)
# -------------------------
all: up

up: init_data
	@$(DCOMPOSE) up -d --build
# Construit les images et démarre les conteneurs en mode détaché

# -------------------------
# Initialisation des dossiers de volumes persistants
# -------------------------
init_data:
	@mkdir -p /home/anastruc/data/wordpress
	@mkdir -p /home/anastruc/data/mariadb
	@sudo chown -R anastruc:anastruc /home/anastruc/data
	@chmod -R 755 /home/anastruc/data
	@echo "Dossiers /home/anastruc/data/wordpress et /home/anastruc/data/mariadb créés et permissions mises à jour"

# Crée les dossiers sur ta VM pour que Docker puisse monter les volumes persos (persistance données)

# -------------------------
# Afficher les logs live de tous les conteneurs
# -------------------------
logs:
	@$(DCOMPOSE) logs --follow
# Affiche les logs de tous les services (suivi en temps réel)

# -------------------------
# Arrêt & suppression des conteneurs déclarés dans le compose
# -------------------------
down:
	@$(DCOMPOSE) down --remove-orphans

restart:
	@$(DCOMPOSE) restart
# Arrête et supprime les conteneurs créés par ce compose file

# -------------------------
# Nettoyage : supprime aussi les images du projet
# -------------------------
clean: down
	-docker image rm -f $$(docker images -q inception-*) || true
	-docker volume rm $(docker volume ls -q | grep inception) || true
	-docker network rm inception_network || true
	@echo "Nettoyage des images, volumes et réseaux du projet terminé."

# Supprime les images Docker du projet dont le nom commence par $(NAME)_
# '|| true' permet d'éviter l'erreur si aucune image ne correspond


# -------------------------
# Nettoyage complet : clean + suppression des données persos (volumes montés)
# -------------------------
fclean: clean
	@sudo rm -rf ~/data/wordpress ~/data/mariadb
	@docker volume prune -f
	@docker network prune -f
# Supprime physiquement les dossiers de données sur ta VM (WordPress/MariaDB)
# + supprime tous les volumes et réseaux inutilisés par Docker
# (⚠️ Cela affecte tous les projets Docker, pas seulement Inception)

# -------------------------
# HARD RESET : “Usine à zéro” (supprime TOUT le Docker non utilisé)
# -------------------------
hardclean:
	@echo "⚠️  HARD RESET : suppression TOTALE des images, volumes, réseaux et données persos"
	@$(DCOMPOSE) down --volumes --remove-orphans
	@docker system prune -af
	@docker volume prune -f
	@docker network prune -f
	@sudo rm -rf ~/data/wordpress ~/data/mariadb
# Cette cible supprime absolument tout :
# - tous les conteneurs, y compris orphelins
# - toutes les images non utilisées
# - tous les volumes Docker inutilisés
# - tous les réseaux Docker inutilisés
# - toutes les données persos WordPress/MariaDB sur ta VM

# -------------------------
# Rebuild complet du projet (fclean + up)
# -------------------------
re: fclean up
# Nettoyage complet + rebuild et relance du projet

# -------------------------
# Fin du Makefile
# -------------------------
.PHONY=re hardclean clean down logs